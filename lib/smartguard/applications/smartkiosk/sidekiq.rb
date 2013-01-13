module Smartguard
  module Applications
    class Smartkiosk
      class Sidekiq < Process
        def start
          super

          Logging.logger.info "Starting sidekiq"

          config_path = @path.join('config/services/sidekiq.yml')
          log_path    = @path.join('log/sidekiq_log')
          pidfile     = @path.join('tmp/pids/sidekiq.pid')

          FileUtils.rm_f pidfile
          if !run(@path,
                  {},
                  "bundle", "exec",
                  "sidekiq", "-e", Smartguard.environment.to_s, "--config=#{config_path}", "--pidfile=#{pidfile}"
                 )
            return false
          end

          without_respawn do
            wait_for_file pidfile
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