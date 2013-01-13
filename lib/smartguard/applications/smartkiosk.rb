module Smartguard
  module Applications
    class Smartkiosk < Smartguard::Application
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
          thin: Thin.new(wrap_path),
          scheduler: Scheduler.new(wrap_path),
        }
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

      def restart(path=nil)
        stop_services(path)
        start_services(path)
      end

      def restart_async(path=nil)
        Thread.new{ self.restart(path) }
        true
      end

      def reboot
        system 'reboot'
      end

      def reboot_async
        Thread.new{ self.reboot }
        true
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
          Logging.logger.info "Installing release gems"
          if !system("bundle", "install", "--local")
            raise "bundle failed"
          end

          Logging.logger.info "Migrating database"
          if !system("bundle", "exec", "rake", "db:migrate", "--trace", "RAILS_ENV=production")
            raise "migration failed"
          end

          Logging.logger.info "Compiling assets"
          if !system("bundle", "exec", "rake", "assets:precompile", "--trace", "RAILS_ENV=production")
            raise "asset precompilation failed"
          end
        end

        self.stop_services

        Logging.logger.info "Switching symlink from `#{@active_path}` to `#{release}`"
        File.delete @current_path if File.symlink? @current_path
        FileUtils.ln_s(release, @current_path)

        @active_path = release if self.start_services do
          Logging.logger.warn "New release `#{release}` did not start!"
          self.stop_services

          Logging.logger.info "Switching symlink back to `#{@active_path}`"
          File.delete @current_path
          FileUtils.ln_s @active_path, @current_path

          self.start_services
        end
      end

      def switch_release_async(release)
        Thread.new{ switch_release(release) }
        true
      end

      def start_services(path=nil, &block)
        @services.each do |key, service|
          service.path = wrap_path path

          if !service.active?
            if !service.start && block_given?
              Logging.logger.debug "Startup of #{s} failed: running safety block"
              yield
              return false
            end
          end
        end
      end

      def stop_services(path=nil)
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