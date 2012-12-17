module Smartguard
  module Applications
    class Smartkiosk
      class Smartware < Smartguard::Process
        def initialize(path)
          @path     = path
          @pid_file = path.join('tmp/pids/smartware.pid')
          @log_file = path.join('log/smartware.log')
        end

        def pid
          File.read(@pid_file).to_i rescue nil
        end

        def start
          Logging.logger.info "Starting smartware"
          run @path, "bundle exec smartware -d --pid=#{@pid_file} --log=#{@log_file}"
        end

        def stop
          Logging.logger.info "Stoping smartware"
          kill unless pid.blank?
        end
      end
    end
  end
end