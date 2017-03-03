class Herodot::Configuration
  CONFIG_FILE = '~/.herodot'.freeze
  def initialize
    @projects_directory = '~'
    @worklog_file = '~/worklog'
    @work_times = {
      work_start: '9:30',
      lunch_break_start: '13:00',
      lunch_break_end: '13:30',
      work_end: '18:00'
    }
  end

  def worklog_file
    File.expand_path(@worklog_file)
  end

  def projects_directory
    File.expand_path(@projects_directory)
  end

  def work_times
    @work_times.map { |k, v| [k, v.split(':').map(&:to_i)] }
  end
end
