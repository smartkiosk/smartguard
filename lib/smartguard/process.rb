module Smartguard
  class Process
    include DRb::DRbUndumped

    def run(path, command)
      result = false

      Bundler.with_clean_env do
        FileUtils.cd(path) do
          result = Kernel.system command
        end
      end

      result
    end

    def kill
      run @path, "kill -9 #{pid}"
    end

    def active?
      !!::Process.getpgid(pid) rescue false
    end
  end
end