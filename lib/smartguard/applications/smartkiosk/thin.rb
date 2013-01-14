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

          if !run(@path,
                  {},
                  "bundle", "exec",
                  "thin", "-e", Smartguard.environment.to_s, "-p", 3000,
                  "start"
                 )
            return false
          end

          without_respawn do
            wait_for_port port
          end
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