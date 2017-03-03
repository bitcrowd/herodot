require 'chronic'
require 'fileutils'

class Herodot::Commands
  SCRIPT = "#!/bin/bash\n"\
           "echo 'Logging into worklog'\n"\
           "project=$(pwd)\n"\
           "branch=$(git rev-parse --abbrev-ref HEAD)\n"\
           'echo "$(date);$project;$branch" >> ~/worklog'.freeze

  def self.show(args)
    subject = args.empty? ? 'this week' : args.join(' ')
    range = Chronic.parse(subject, guess: false, context: :past)
    abort "Date not parsable: #{args.join(' ')}" unless range
    worklog = Herodot::Parser.parse(range)
    output = Herodot::Table.print(worklog.totals)
    puts output
  end

  def self.track(path)
    path = '.' if path.nil?
    hooks = "#{path}/.git/hooks"
    if File.exist?(hooks)
      %w(post-checkout post-commit).each do |name|
        File.open("#{hooks}/#{name}", 'w') { |file| file.write(SCRIPT) }
        File.chmod(0o755, "#{hooks}/#{name}")
      end
    else
      abort('Path is not a git repository.')
    end
  end
end
