module Smartguard
  module Applications
    class Smartkiosk
      class Web < Process
        def start
          super

          if Smartguard.environment == :development
            Logging.logger.info "Skipping web; Please run manually with `rack web`".black_on_white.bold
            return true
          else
            Logging.logger.info "Starting web"
          end

          log_path = @path.join('log/web.log')

          if !run(@path, {
                  'RACK_ENV' => Smartguard.environment.to_s
                },
                  "bundle", "exec",
                  "rack", "web"
                 )
            return false
          end

          result = without_respawn do
            wait_for_port 3001
          end

          result
        end

        def stop
          super

          Logging.logger.info "Stoping web"
          kill_and_wait :TERM, 15
        end
      end
    end
  end
end