module Smartguard
  module Applications
    class Smartkiosk < Smartguard::Application
      def initialize(*args)
        super
        @head_path = @base_path.join('head')
      end

      def services
        [:sidekiq, :smartware, :cronic, :thin]
      end

      def status
        data = {}

        services.each do |s|
          service = send(s)

          data[s] = [service.pid, service.active?]
        end

        data
      end

      def warm_up
        Logging.logger.info 'Warming up'

        services.each do |s|
          service = send(s)

          if !service.active?
            if !service.start
              stop_services
              puts "Could not be started: #{s}"
              exit
            end
          else
            Logging.logger.info "#{s} is already active: #{service.pid}"
          end
        end
      end

      def restart(path=nil)
        stop_services(path)
        start_services(path)
      end

      def restart_asyn(path=nil)
        Thread.new{ self.restart(path) }
        true
      end

      def switch_release(release)
        release = release.is_a?(Symbol) ? @releases_path.join(release.to_s)
                                        : @base_path.join(release)

        raise "Release doesn't exist: #{release.to_s}" unless File.exist? release

        FileUtils.cd(release) do
          Logging.logger.info "Installing release gems"
          `bundle install`

          Logging.logger.info "Migrating database"
          `bundle exec rake db:migrate --trace  RAILS_ENV=production`

          Logging.logger.info "Compiling assets"
          `bundle exec rake assets:precompile --trace RAILS_ENV=production`
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
        services.each do |s|
          if !send(s, path).start && block_given?
            Logging.logger.debug "Startup of #{s} failed: running safety block"
            yield 
            return false
          end
        end
      end

      def stop_services(path=nil)
        services.each do |s|
          send(s, path).stop
        end
      end

    protected

      def sidekiq(path=nil)
        Sidekiq.new wrap_path(path)
      end

      def smartware(path=nil)
        Smartware.new wrap_path(path)
      end

      def cronic(path=nil)
        Cronic.new wrap_path(path)
      end

      def thin(path=nil)
        Thin.new wrap_path(path)
      end

      def wrap_path(path)
        path.blank? ? @current_path : Pathname.new(path)
      end
    end
  end
end