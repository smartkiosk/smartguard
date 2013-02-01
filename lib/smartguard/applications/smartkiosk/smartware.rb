module Smartguard
  module Applications
    class Smartkiosk
      class Smartware < Process
        def start
          super

          Logging.logger.info "Starting smartware"

          log_file    = @path.join('log/smartware.log')
          config_file = @path.join('config/services/smartware.yml')

          opts = []
          if Smartguard.environment == :production
            opts << "--log=#{log_file}"
          end

          if !run(@path, {}, "bundle", "exec", "smartware", "--config=#{config_file}", *opts)
            return false
          end

          without_respawn do
            wait_for_port 6001
          end
        end

        def stop
          super

          Logging.logger.info "Stoping smartware"
          kill_and_wait :TERM, 15
        end
      end
    end
  end
end