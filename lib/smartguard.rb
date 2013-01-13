require 'active_support/all'
require 'pathname'
require 'fileutils'
require 'drb'

require 'smartguard/version'
require 'smartguard/logging'
require 'smartguard/process'
require 'smartguard/process_manager'
require 'smartguard/application'
require 'smartguard/client'

require 'smartguard/applications/smartkiosk'
require 'smartguard/applications/smartkiosk/process'
require 'smartguard/applications/smartkiosk/sidekiq'
require 'smartguard/applications/smartkiosk/smartware'
require 'smartguard/applications/smartkiosk/cronic'
require 'smartguard/applications/smartkiosk/thin'

module Smartguard
end
