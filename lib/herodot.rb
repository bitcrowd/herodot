require 'rubygems'
require 'bundler/setup'
require 'herodot/version'
require 'herodot/configuration'
require 'herodot/worklog'
require 'herodot/parser'
require 'herodot/commands'
require 'herodot/table'
require 'commander'

class Herodot::Application
  include Commander::Methods
  USER_HOME = File.expand_path('~').to_s

  def run
    program :name, 'herodot'
    program :version, Herodot::VERSION
    program :description, 'Tracks your work based on git branch checkouts'

    config = Herodot::Configuration.new
    track_command
    show_command(config)

    run!
  end

  def track_command
    command :track do |c|
      c.syntax = 'herodot track <repository path>'
      c.summary = ''
      c.description = ''
      c.example 'herodot track', ''
      c.action do |args, _|
        Herodot::Commands.track(args[0])
      end
    end
  end

  def show_command(config)
    command :show do |c|
      c.syntax = 'herodot show [<time range>]'
      c.summary = 'Shows worklogs'
      c.description = ''
      show_command_examples(c)
      c.action do |args, _options|
        Herodot::Commands.show args, config
      end
    end
  end

  def show_command_examples(c)
    c.example 'Shows this weeks worklogs', 'herodot show'
    c.example 'Shows last weeks worklogs', 'herodot show last week'
    c.example 'Shows worklogs for last monday', 'herodot show monday'
    c.example 'Shows worklogs for 12-12-2016', 'herodot show 12-12-2016'
  end
end
