module Smartguard
  module Applications
    class Smartkiosk
      class Sidekiq < Smartguard::Process
        def initialize(path)
          @path        = path
          @config_path = path.join('config/sidekiq.yml')
          @log_path    = path.join('log/sidekiq_log')
          @config      = YAML.load_file(@config_path) rescue {}
        end

        def pid
          File.read(@path.join @config[:pidfile]).to_i rescue nil
        end

        def start
          Logging.logger.info "Starting sidekiq"

          if @config[:pidfile].blank?
            Logging.logger.warn "Sidekiq's config was not found"
            return false
          end

          run @path, "bundle exec sidekiq -e production --config #{@config_path} >> #{@log_path} 2>&1 &"
        end

        def stop
          Logging.logger.info "Stoping sidekiq"
          run @path, "bundle exec sidekiqctl stop #{@config[:pidfile]} 60"
        end
      end
    end
  end
end