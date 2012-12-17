module Smartguard
  class Process
    include DRb::DRbUndumped

    def run(path, command, env={})
      result = false

      if defined?(Bundler)
        Bundler.with_clean_env do
          env = ENV.to_hash.merge(env)

          FileUtils.cd(path) do
            result = Kernel.system env, command
          end
        end
      else
        env = ENV.to_hash.merge(env)

        FileUtils.cd(path) do
          result = Kernel.system env, command
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