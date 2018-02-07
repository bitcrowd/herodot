
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'herodot/version'

Gem::Specification.new do |spec|
  spec.name          = 'herodot'
  spec.version       = Herodot::VERSION
  spec.authors       = ['bitcrowd']
  spec.email         = ['info@bitcrowd.net']
  spec.summary       = 'Track your work with your git activity.'
  spec.description   = 'With herodot you can track the times you spend on a '\
                       'git branch. When using a branch for each ticket you '\
                       'work on, herodot helps you with your time tracking.'
  spec.homepage      = 'https://github.com/bitcrowd/herodot'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = %w[herodot]
  spec.require_paths = %w[lib]

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-bitcrowd'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_dependency 'chronic'
  spec.add_dependency 'commander'
  spec.add_dependency 'rainbow'
  spec.add_dependency 'terminal-table'
end
