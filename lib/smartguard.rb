require 'active_support/all'
require 'pathname'
require 'fileutils'
require 'socket'
require 'eventmachine'
require 'amqp'
require 'json'

require 'smartkiosk/common'

require 'smartguard/version'
require 'smartguard/logging'
require 'smartguard/process'
require 'smartguard/process_manager'
require 'smartguard/application'
require 'smartguard/client'

require 'smartguard/applications/smartkiosk'
require 'smartguard/applications/smartkiosk/sidekiq'
require 'smartguard/applications/smartkiosk/smartware'
require 'smartguard/applications/smartkiosk/scheduler'
require 'smartguard/applications/smartkiosk/web'

module Smartguard
  class << self
    attr_accessor :environment
    attr_accessor :shutting_down
  end

  self.shutting_down = false
end
