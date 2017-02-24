require 'herodot/version'
require 'herodot/worklog'
require 'rubygems'
require 'commander'

module Herodot
  class Application
    include Commander::Methods

    def run
      program :name, 'herodot'
      program :version, VERSION
      program :description, 'Tracks your work based on git branch checkouts'

      track_command
      log_command

      run!
    end

    def track_command
      command :track do |c|
        c.syntax = 'herodot track [options]'
        c.summary = ''
        c.description = ''
        c.example 'description', 'command example'
        c.option '--some-switch', 'Some switch that does something'
        c.action do |args, options|
          # Do something or c.when_called Herodot::Commands::Track
        end
      end
    end

    def log_command
      command :list do |c|
        c.syntax = 'herodot list [options]'
        c.summary = ''
        c.description = ''
        c.example 'description', 'command example'
        c.option '--some-switch', 'Some switch that does something'
        c.action do |args, options|
          Worklog.new.list
        end
      end
    end
  end
end
