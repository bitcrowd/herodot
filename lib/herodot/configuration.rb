require 'yaml'

class Herodot::Configuration
  CONFIG_FILE = File.expand_path('~/.herodot.yml').freeze
  DEFAULT_CONFIGURATION = {
    'projects_directory' => '~',
    'work_times' => {
      'work_start' => '9:30',
      'lunch_break_start' => '13:00',
      'lunch_break_end' => '13:30',
      'work_end' => '18:00'
    }
  }.freeze

  def initialize
    @worklog_file = '~/worklog'
    if File.exist?(CONFIG_FILE)
      @config = load_configuration
    else
      @config = DEFAULT_CONFIGURATION
      save_configuration
    end
  end

  def worklog_file
    File.expand_path(@worklog_file)
  end

  def projects_directory
    File.expand_path(@config['projects_directory'])
  end

  def work_times
    @config['work_times'].map { |k, v| [k.to_sym, v.split(':').map(&:to_i)] }
  end

  def save_configuration
    File.open(CONFIG_FILE, 'w') { |f| YAML.dump(@config, f) }
  end

  def load_configuration
    File.open(CONFIG_FILE) { |f| YAML.load(f) }
  end
end
