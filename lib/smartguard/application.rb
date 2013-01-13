module Smartguard
  class Application
    attr_reader :releases_path, :current_path, :shared_path, :active_path

    def initialize(path)
      @base_path = Pathname.new(File.absolute_path path)

      if Smartguard.environment == :production
        @current_path  = @base_path.join('current')
        @releases_path = @base_path.join('releases')
        @shared_path   = @base_path.join('shared')
        @active_path   = File.readlink @current_path
      else
        @current_path  = @base_path
        @releases_path = @base_path.join('tmp/releases')
        @shared_path   = @base_path
        @active_path   = @base_path
      end
    end
  end
end