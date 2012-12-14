module Smartguard
  class Client
    def initialize(port=10000)
      DRb.start_service
      @instance = DRbObject.new_with_uri("druby://localhost:#{port}")
    end

    def method_missing(method, *args, &block)
      @instance.send method, *args, &block
    end
  end
end