require 'active_support/all'
require 'pathname'
require 'fileutils'
require 'drb'
require 'socket'

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
require 'smartguard/applications/smartkiosk/thin'

module Smartguard
  class << self
    attr_accessor :environment
  end
end
