# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'herodot/version'

Gem::Specification.new do |spec|
  spec.name          = 'herodot'
  spec.version       = Herodot::VERSION
  spec.authors       = ['Andreas Knöpfle']
  spec.email         = ['andreas.knoepfle@gmail.com']
  spec.summary       = 'Track you work with git branches'
  spec.description   = 'With herodot you can track the times you spend on a '\
                       'git branch. When using a branch for each ticket you '\
                       'work on, herodot helps you with your time tracking.'
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = %w(herodot)
  spec.require_paths = %w(lib)

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_dependency 'terminal-table'
  spec.add_dependency 'chronic'
  spec.add_dependency 'commander'
end
