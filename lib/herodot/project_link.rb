module Herodot
  class ProjectLink
    PROJECT_CONFIG = '.herodot.yml'.freeze

    def self.project_config_file(path)
      File.join(File.expand_path(path), PROJECT_CONFIG)
    end

    def self.link(path, link, pattern)
      puts "Write link into #{project_config_file(path)}"
      File.open(project_config_file(path), 'w') do |f|
        YAML.dump({ link: link, pattern: pattern }, f)
      end
    end

    def initialize(worklog)
      @worklog = worklog
      @project_configurations = {}
    end

    def totals
      @worklog.totals.map do |date, logs|
        [date, decorated_logs(logs)]
      end
    end

    private

    def decorated_logs(logs)
      logs.map do |log|
        decorated_log(log)
      end
    end

    def decorated_log(log)
      link = issue_management_link(log)
      return log if link.nil?
      log.merge(link: link)
    end

    def issue_management_link(log)
      config = @project_configurations.fetch(log[:path], load_project_configuration(log[:path]))
      return nil unless config.fetch(:link, false)
      ticket = log[:branch].scan(Regexp.new(config.fetch(:pattern, /$^/)))
      [config[:link], ticket.first].join if ticket.any?
    end

    def load_project_configuration(path)
      file = self.class.project_config_file(path)
      return { link: false } unless File.exist?(file)
      File.open(file) { |f| YAML.load(f) }
    end
  end
end
