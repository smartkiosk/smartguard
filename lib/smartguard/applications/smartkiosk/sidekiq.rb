require "fileutils"

module Smartguard
  module Applications
    class Smartkiosk
      class Sidekiq < Process
        def initialize(path)
          super

          @config_path = path.join('config/sidekiq.yml')
          @log_path    = path.join('log/sidekiq_log')
          @pidfile     = path.join('tmp/pids/sidekiq.pid')
          @config      = YAML.load_file(@config_path) rescue {}
        end

        def start
          super

          Logging.logger.info "Starting sidekiq"

          FileUtils.rm_f @pidfile
          if !run(@path, {}, "bundle", "exec", "sidekiq", "-e", "production", "--config=#{@config_path}", "--pidfile=#{@pidfile}")
            return false
          end

          without_respawn do
            wait_for_file @pidfile
          end
        end

        def stop
          super

          Logging.logger.info "Stopping sidekiq"
          kill_and_wait :TERM, 60
        end
      end
    end
  end
end