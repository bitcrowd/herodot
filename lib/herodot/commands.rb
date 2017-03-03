require 'chronic'
require 'fileutils'

class Herodot::Commands
  SCRIPT = "#!/bin/bash\n"\
           "echo 'Logging into worklog'\n"\
           "project=$(pwd)\n"\
           "branch=$(git rev-parse --abbrev-ref HEAD)\n"\
           'echo "$(date);$project;$branch" >> ~/worklog'.freeze
  DEFAULT_RANGE = 'this week'.freeze

  def self.show(args, config)
    subject = args.empty? ? DEFAULT_RANGE : args.join(' ')
    range = Chronic.parse(subject, guess: false, context: :past)
    abort "Date not parsable: #{args.join(' ')}" unless range
    worklog = Herodot::Parser.parse(range, config)
    output = Herodot::Table.print(worklog.totals)
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
    end
  end
end
