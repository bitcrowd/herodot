require 'commander'
require 'rainbow'
require_relative 'herodot/version'
require_relative 'herodot/configuration'
require_relative 'herodot/worklog'
require_relative 'herodot/parser'
require_relative 'herodot/commands'
require_relative 'herodot/output'
require_relative 'herodot/project_link'

class Herodot::Application
  include Commander::Methods
  USER_HOME = File.expand_path('~').to_s

  def run
    program :name, 'herodot'
    program :version, Herodot::VERSION
    program :description, 'Tracks your work based on git branch checkouts'

    config = Herodot::Configuration.new
    init_command(config)
    show_command(config)
    link_command(config)
    default_command :show
    run!
  end

  INIT_DESCRIPTION = 'This command sets up post commit and post checkout hooks'\
                      ', that will log the current branch into the worklog file.'.freeze
  def init_command(config)
    command :init do |c|
      c.syntax = 'herodot init [<repository path>]'
      c.summary = 'Start tracking a repository'
      c.description = INIT_DESCRIPTION
      c.example 'Start tracking current repository', 'herodot init'
      c.action do |args, _|
        Herodot::Commands.init(args[0], config)
      end
    end
  end

  SHOW_DESCRIPTION = 'This command parses the worklog file and returns the'\
                     'git branch based worklog according to the'\
                     'work times specified in the `~/.herodot.yml`.'.freeze
  def show_command(config)
    command :show do |c|
      c.syntax = 'herodot show [<time range>]'
      c.summary = 'Shows worklogs'
      c.description = SHOW_DESCRIPTION
      c.option '--format FORMAT', String, 'Uses specific output format (Supported: json)'
      show_command_examples(c)
      c.action do |args, options|
        Herodot::Commands.show(args, config, options)
      end
    end
  end

  LINK_DESCRIPTION = 'This command can link a repository to a project issue tracking tool.'\
                     ' The commmands writes the settings in `project_path/.herodot.yml`.'.freeze
  def link_command(_)
    command :link do |c|
      c.syntax = 'herodot link [<repository path>]'
      c.summary = 'Link project with issue tracker'
      c.description = SHOW_DESCRIPTION
      c.example 'Link current repository', 'herodot link'
      c.action do |args, _|
        Herodot::Commands.link(args[0])
      end
    end
  end

  def show_command_examples(c)
    c.example 'Shows this weeks worklogs', 'herodot show'
    c.example 'Shows last weeks worklogs', 'herodot show last week'
    c.example 'Shows worklogs for last monday', 'herodot show monday'
    c.example 'Shows worklogs for 12-12-2016', 'herodot show 12-12-2016'
    c.example 'Shows last weeks worklogs as json', 'herodot show --format json last week'
    c.example 'Shows last weeks worklogs as json (short)', 'herodot show -f json last week'
  end
end
