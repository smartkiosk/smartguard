module Smartguard
  module Applications
    class Smartkiosk
      class Cronic < Smartguard::Process
        def initialize(path)
          @path     = path
          @pid_file = path.join('tmp/pids/cronic.pid')
          @log_file = path.join('log/cronic.log')
        end

        def pid
          File.read(@pid_file).to_i rescue nil
        end

        def start
          Logging.logger.info "Starting cronic"
          run @path, "script/cronic -d -l #{@log_file} -P #{@pid_file}", 'RAILS_ENV' => 'production'
        end

        def stop
          Logging.logger.info "Stoping cronic"
          run @path, "script/cronic -k -P #{@pid_file}"
        end
      end
    end
  end
end