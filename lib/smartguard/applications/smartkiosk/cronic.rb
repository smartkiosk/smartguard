require "fileutils"

module Smartguard
  module Applications
    class Smartkiosk
      class Cronic < Process
        def initialize(path)
          super
          @log_file = path.join('log/cronic.log')
          @pidfile  = path.join('tmp/pids/cronic.pid')
        end

        def start
          super

          Logging.logger.info "Starting cronic"

          FileUtils.rm_f @pidfile

          if !run(@path, {
              'RAILS_ENV' => 'production'
            }, "bundle", "exec", "script/cronic", "-l", "#{@log_file}", "-P", "#{@pidfile}")
            return false
          end

          # FIXME: cannot get cronic to start properly.
          # job Rufus::Scheduler::EveryJob_30974480 caught exception 'Tried to use a connection from a child process without reconnecting. You need to reconnect to Redis after forking.'
=begin
          without_respawn do
            wait_for_file @pidfile
          end
=end
          true
        end

        def stop
          super

          Logging.logger.info "Stoping cronic"
          kill_and_wait :TERM
        end
      end
    end
  end
end