module Smartguard
  module Applications
    class Smartkiosk
      class Thin < Process
        def start
          super

          Logging.logger.info "Starting thin"

          if Smartguard.environment == :development
            port = 3001
          else
            port = 3000
          end

          if !run(@path,
                  {},
                  "bundle", "exec",
                  "thin", "-e", Smartguard.environment.to_s, "-p", port.to_s,
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