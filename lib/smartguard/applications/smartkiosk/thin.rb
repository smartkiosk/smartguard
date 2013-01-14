module Smartguard
  module Applications
    class Smartkiosk
      class Thin < Process
        def start
          super

          if Smartguard.environment == :development
            Logging.logger.info "Skipping thin; Please run manually".black_on_white.bold
            return true
          else
            Logging.logger.info "Starting thin"
          end

          log_path = @path.join('log/thin.log')

          if !run(@path,
                  {},
                  "bundle", "exec",
                  "thin", "-e", Smartguard.environment.to_s, "-p", "3000", "-l", "#{log_path}",
                  "start"
                 )
            return false
          end

          result = without_respawn do
            wait_for_port 3000
          end

          result
        end

        def stop
          super

          Logging.logger.info "Stoping thin"
          kill_and_wait :TERM, 15
        end
      end
    end
  end
end