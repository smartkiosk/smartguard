module Smartguard
  class Application
    def initialize(path)
      @base_path     = Pathname.new(File.absolute_path path)
      @current_path  = @base_path.join('current')
      @releases_path = @base_path.join('releases')
      @shared_path   = @base_path.join('shared')
      @active_path   = File.readlink @current_path
    end
  end
end