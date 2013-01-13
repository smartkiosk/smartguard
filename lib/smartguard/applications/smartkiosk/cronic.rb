require "fileutils"

module Smartguard
  module Applications
    class Smartkiosk
      class Cronic < Process
        def start
          super

          Logging.logger.info "Starting cronic"

          log_file = @path.join('log/cronic.log')


          run @path, {
              'RAILS_ENV' => 'production'
            }, "bundle", "exec", "script/cronic", "-l", "#{log_file}"
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