# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'smartguard/version'

Gem::Specification.new do |gem|
  gem.name          = "smartguard"
  gem.version       = Smartguard::VERSION
  gem.authors       = ["Boris Staal"]
  gem.email         = ["boris@roundlake.ru"]
  gem.description   = %q{Smartguard is the Smartkiosk services control daemon}
  gem.summary       = gem.description
  gem.homepage      = "https://github.com/roundlake/smartguard"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'smartkiosk-common'
  gem.add_dependency 'i18n'
  gem.add_dependency 'activesupport'
  gem.add_dependency 'trollop'
  gem.add_dependency 'colored'

  gem.add_development_dependency 'pry'
end
