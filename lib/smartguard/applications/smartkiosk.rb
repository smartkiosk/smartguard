module Smartguard
  module Applications
    class Smartkiosk < Smartguard::Application
      COMMANDS = [
        :services, :status,
        :start, :stop, :restart,
        :switch_release, :reboot,
      ]

      def initialize(*args)
        super

        if Smartguard.environment == :production
          @head_path = @base_path.join('head')
        else
          @head_path = @base_path
        end

        @services = {
          smartware: Smartware.new(wrap_path),
          sidekiq: Sidekiq.new(wrap_path),
          web: Web.new(wrap_path),
          scheduler: Scheduler.new(wrap_path),
        }
      end

      def dispatch_command(command, *args)
        command = command.to_sym
        raise "unsupported command #{command}" unless COMMANDS.include? command

        send command, *args
      end

      def services
        @services.keys
      end

      def status
        data = {}

        @services.each do |key, service|
          data[key] = [ service.pid, service.active? ]
        end

        data
      end

      def restart(path = nil)
        stop(path)
        start(path)
      end

      def reboot
        Process.spawn 'reboot'
      end

      def switch_release(release)
        if Smartguard.environment != :production
          raise "Release switching is only supported in the production environment."
        end

        release = release.is_a?(Symbol) ? @releases_path.join(release.to_s)
                                        : @base_path.join(release)

        raise "Release doesn't exist: #{release.to_s}" unless File.exist? release

        FileUtils.mkdir_p "#{release}/tmp/pids"

        FileUtils.cd(release) do
          Logging.logger.info "Symlinking"
          FileUtils.rm_rf "config/services"
          FileUtils.rm_rf "public/uploads"
          FileUtils.ln_s "#{@shared_path.join 'config'}", "config/services"
          FileUtils.ln_s "#{@shared_path.join 'uploads'}", "public/uploads"

          FileUtils.rm_f "config/database.yml"
          FileUtils.ln_s "services/database.yml", "config/database.yml"

          Logging.logger.info "Installing release gems"
          if !system("bundle", "install", "--local")
            raise "bundle failed"
          end

          Logging.logger.info "Migrating database"
          if !system("bundle", "exec", "rake", "db:migrate", "--trace", "RACK_ENV=production")
            raise "migration failed"
          end
        end

        begin
         yield if block_given?
        rescue Exception => e
          Logging.logger.warn "Switch handler failed: #{e}"
        end

        self.stop

        Logging.logger.info "Switching symlink from `#{@active_path}` to `#{release}`"
        File.delete @current_path if File.symlink? @current_path
        FileUtils.ln_s(release, @current_path)

        @active_path = release if self.start do
          Logging.logger.warn "New release `#{release}` did not start!"
          self.stop

          Logging.logger.info "Switching symlink back to `#{@active_path}`"
          File.delete @current_path
          FileUtils.ln_s @active_path, @current_path

          self.start
        end
      end

      def start(path=nil, &block)
        @services.each do |key, service|
          service.path = wrap_path path

          if !service.active?
            if !service.start && block_given?
              Logging.logger.debug "Startup of #{key} failed: running safety block"
              yield
              return false
            end
          end
        end
      end

      def stop(path=nil)
        @services.each do |key, service|
          service.path = wrap_path path

          service.stop if service.active?
        end
      end

    protected

      def wrap_path(path = nil)
        path.blank? ? @current_path : Pathname.new(path)
      end
    end
  end
end