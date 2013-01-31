module Smartguard
  module Client

    DRb.start_service
    @instance = DRbObject.new_with_uri('druby://localhost:10000')

    class << self
      def method_missing(method, *args, &block)
        @instance.send method, *args, &block
      end
    end
  end
end