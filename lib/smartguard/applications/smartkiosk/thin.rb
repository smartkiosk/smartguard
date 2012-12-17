module Smartguard
  module Applications
    class Smartkiosk
      class Thin < Smartguard::Process
        def initialize(path)
          @path     = path
          @pid_file = path.join('tmp/pids/thin.pid')
        end

        def pid
          File.read(@pid_file).to_i rescue nil
        end

        def start
          Logging.logger.info "Starting thin"
          run @path, "bundle exec thin -d -e production start"
        end

        def stop
          Logging.logger.info "Stoping thin"
          run(@path, "bundle exec thin -d -e production stop") unless pid.blank?
        end
      end
    end
  end
end