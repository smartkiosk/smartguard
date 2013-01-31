module Smartguard
  class Application
    attr_reader :releases_path, :current_path, :shared_path, :active_path
    attr_reader :amqp_connection, :amqp_channel, :guard_commands, :guard_status

    def initialize(path, broker)
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

      @amqp_connection = AMQP.connect broker
      @amqp_channel    = AMQP::Channel.new @amqp_connection
      @guard_commands  = @amqp_channel.fanout "smartguard.commands", auto_delete: true
      @guard_status    = @amqp_channel.topic "smartguard.events", auto_delete: true

      command_queue = @amqp_channel.queue '', exclusive: true
      command_queue.bind @guard_commands
      command_queue.subscribe &method(:command)
    end

    def post_event(event, *args)
      EventMachine.schedule do
        @guard_status.publish JSON.dump(args), routing_key: event
      end
    end

    private

    def command(header, data)
      data = JSON.load data

      operation = ->() do
        post_event "command.#{data["id"]}.started"

        begin
          dispatch_command *data["command"]
        rescue => e
          e
        end
      end

      callback = ->(result) do
        if result.respond_to? :exception
          post_event "command.#{data["id"]}.finished", nil, result.to_s
        else
          post_event "command.#{data["id"]}.finished", result
        end
      end

      EventMachine.defer operation, callback
    end
  end
end