module Smartguard
  class Process
    include DRb::DRbUndumped

    attr_reader :pid

    private

    def initialize
      @active = false
      @pid = nil
    end

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

    def process_died(pid)
      @active = false
      @pid = nil
    end

    public

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

    def active?
      @active
    end
  end
end