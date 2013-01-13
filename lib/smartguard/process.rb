module Smartguard
  class Process
    include DRb::DRbUndumped

    attr_reader :pid
    attr_accessor :path

    def initialize(path)
      @active = false
      @pid = nil
      @path = path
      @wanted = false
      @starting = false
    end

    private

    def run_clean(path, env={}, *command)
      raise "process is already active" if @active

      begin
        @pid = ::Process.spawn env, *command, chdir: path
        ProcessManager.track @pid, method(:process_died)
        @active = true

        true
      rescue => e
        Logging.logger.error "unable to spawn #{command[0]}: #{e}"
        false
      end
    end

    public

    def start
      @wanted = true
    end

    def stop
      @wanted = false
    end

    def active?
      @active
    end

    def wanted?
      @wanted
    end

    protected

    def died
      Thread.new do
        Logging.logger.warn "#{self.class.name} died, respawning"
        start
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
        alive = false
        Addrinfo.foreach("localhost", port) do |addr|
          begin
            socket = Socket.new addr.afamily, :STREAM

            socket.connect addr.to_sockaddr
            alive = true
          rescue
          ensure
            socket.close unless socket.nil?
          end

          break if alive
        end

        break if alive
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

    def process_died(pid)
      @active = false
      @pid = nil

      died if @wanted && !@starting
    end

    if defined? Bundler
      def run(*args)
        Bundler.with_clean_env do
          run_clean *args
        end
      end
    else
      alias :run :run_clean
    end

    def kill_and_wait(signal = :TERM, timeout = nil)
      kill signal
      wait timeout
    end

    def kill(signal = :TERM)
      if active?
        ::Process.kill signal, @pid
      end

      true
    rescue
      true
    end

    def wait(timeout = nil)
      started = Time.now

      while active?
        sleep 0.5

        now = Time.now
        if !timeout.nil? && now - started > timeout
          begin
            @active = false
            ProcessManager.untrack @pid
            Process.kill :KILL, @pid
          rescue
          end

          return true
        end
      end

      true
    end
  end
end