require "fileutils"

module Smartguard
  module Applications
    class Smartkiosk
      class Scheduler < Process
        def start
          super

          Logging.logger.info "Starting scheduler"

          run @path, {
              'RAILS_ENV' => 'production'
            }, "rake", "schedule"
        end

        def stop
          super

          Logging.logger.info "Stoping scheduler"
          kill_and_wait :TERM, 5
        end
      end
    end
  end
end