module Smartguard
  module Applications
    class Smartkiosk
      class Smartware < Process
        def initialize(path)
          super

          @log_file    = path.join('log/smartware.log')
          @config_file = path.join('config/smartware.yml')
        end

        def start
          super

          Logging.logger.info "Starting smartware"
          if !run(@path, {}, "bundle", "exec", "smartware", "--log=#{@log_file}", "--config-file=#{@config_file}")
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