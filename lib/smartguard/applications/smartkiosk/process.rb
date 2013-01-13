module Smartguard
  module Applications
    class Smartkiosk
      class Process < Smartguard::Process
        attr_accessor :path, :wanted

        def initialize(path)
          super()

          @path = path
          @wanted = false
          @starting = false
        end

        def start
          @wanted = true
        end

        def stop
          @wanted = false
        end

        def died
          unless @starting
            Thread.new do
              Logging.logger.warning "#{self.class.name} died, respawning"
              start
            end
          end
        end

        def without_respawn(&block)
          begin
            @starting = true

            yield
          ensure
            @starting = false
          end
        end

        def wait_for_port(port)
          while active?
            socket = nil
            thin_alive = false
            begin
              socket = Socket.new :INET, :STREAM

              socket.connect Socket.sockaddr_in(port, "127.0.0.1")
              thin_alive = true
            rescue
            ensure
              socket.close unless socket.nil?
            end

            break if thin_alive
            sleep 0.5
          end

          active?
        end

        def wait_for_file(file)
          while active?
            break if File.exists? file
            sleep 0.5
          end

          active?
        end

        protected

        def process_died(pid)
          super

          died if @wanted
        end
      end
    end
  end
end
