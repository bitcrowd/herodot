require 'chronic'
require 'fileutils'

class Herodot::Commands
  SCRIPT = "#!/bin/bash\n"\
           "echo 'Logging into worklog'\n"\
           "project=$(pwd)\n"\
           "branch=$(git rev-parse --abbrev-ref HEAD)\n"\
           'echo "$(date);$project;$branch" >> ~/worklog'.freeze
  DEFAULT_RANGE = 'this week'.freeze

  def self.show(args, config, opts = {})
    subject = args.empty? ? DEFAULT_RANGE : args.join(' ')
    range = Chronic.parse(subject, guess: false, context: :past)
    abort "Date not parsable: #{args.join(' ')}" unless range
    worklog = Herodot::Parser.parse(range, config)
    decorated_worklog = Herodot::ProjectLink.new(worklog)
    output = Herodot::Output.print(decorated_worklog.totals, opts)
    puts output
  end

  def self.track(path, config)
    path = '.' if path.nil?
    puts "Start tracking of `#{File.expand_path(path)}` into `#{config.worklog_file}`."
    hooks = "#{path}/.git/hooks"
    abort('Path is not a git repository.') unless File.exist?(hooks)
    %w(post-checkout post-commit).each do |name|
      File.open("#{hooks}/#{name}", 'w') { |file| file.write(SCRIPT) }
      File.chmod(0o755, "#{hooks}/#{name}")
      FileUtils.touch(config.worklog_file)
    end
  end

  def self.link(path)
    path = '.' if path.nil?
    choose do |menu|
      menu.prompt = 'What tracker do you want to link to?'
      menu.choice(:jira) { link_jira(path) }
      menu.choice(:github) { link_github(path) }
      menu.choice(:gitlab) { link_gitlab(path) }
      menu.choices(:other) { link_other(path) }
      menu.default = :other
    end
  end

  def self.link_jira(path)
    prefix = ask('Jira URL prefix (something for https://something.atlassian.net)?')
    pattern = ask('Ticket prefix (ABCD for tickets like ABCD-123)')
    Herodot::ProjectLink.link(path, "http://#{prefix}.atlassian.net/browse/", "#{pattern}-\\d+")
  end

  def self.link_github(path)
    handle = ask('Github handle (something/something for https://github.com/something/something)?')
    Herodot::ProjectLink.link(path, "https://github.com/#{handle}/issues/", '\\d+')
  end

  def self.link_gitlab(path)
    handle = ask('GitLab handle (something/something for https://gitlab.com/something/something)?')
    Herodot::ProjectLink.link(path, "https://gitlab.com/#{handle}/issues/", '\\d+')
  end

  def self.link_other(path)
    url = ask('URL to issue tracker:')
    pattern = ask('Ticket regex pattern (ruby):')
    Herodot::ProjectLink.link(path, url, pattern)
  end
end
