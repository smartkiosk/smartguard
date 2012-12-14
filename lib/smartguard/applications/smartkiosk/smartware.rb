module Smartguard
  module Applications
    class Smartkiosk
      class Smartware < Smartguard::Process
        def initialize(path)
          @path      = path
          @pids_path = path.join('tmp/pids')
          @logs_path = path.join('log')
        end

        def pid
          File.read("#{@pids_path}/smartware.pid").to_i rescue nil
        end

        def start
          Logging.logger.info "Starting smartware"
          run @path, "bundle exec smartware piddir=#{@pids_path} logdir=#{@logs_path} &"
        end

        def stop
          Logging.logger.info "Stoping smartware"
          kill unless pid.blank?
        end
      end
    end
  end
end