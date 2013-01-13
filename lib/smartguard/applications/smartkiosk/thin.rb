module Smartguard
  module Applications
    class Smartkiosk
      class Thin < Process
        def start
          super

          Logging.logger.info "Starting thin"

          if !run(@path, {}, "bundle", "exec", "thin", "-e", "production", "start")
            return false
          end

          without_respawn do
            wait_for_port 3000
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