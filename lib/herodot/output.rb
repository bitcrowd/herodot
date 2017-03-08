require 'terminal-table'
require 'json'

class Herodot::Output
  HEADERS = %w(Project Branch Time).freeze
  EMPTY_WORKLOG_MESSAGE = Rainbow('Not enough entries in the worklog.').red +
                          ' On a tracked repository `git checkout`'\
                          ' and `git commit` will add entries.'.freeze
  COLORS = %i(green yellow blue magenta cyan aqua silver aliceblue indianred).freeze

  class << self
    def format_time(time_is_seconds)
      total_seconds = time_is_seconds.to_i
      seconds = total_seconds % 60
      minutes = (total_seconds / 60) % 60
      hours = total_seconds / (60 * 60)
      "#{hours}:#{minutes.to_s.rjust(2, '0')}:#{seconds.to_s.rjust(2, '0')}"
    end

    def print(worklogs_totals_per_day, opts)
      return convert_format(worklogs_totals_per_day, opts.format) if opts.format
      print_table(worklogs_totals_per_day)
    end

    def convert_format(worklogs_totals_per_day, format)
      case format
      when 'json'
        worklogs_totals_per_day.to_json
      end
    end

    def print_table(worklogs_totals_per_day)
      abort EMPTY_WORKLOG_MESSAGE if worklogs_totals_per_day.empty?
      Terminal::Table.new(headings: HEADERS) do |table|
        worklogs_totals_per_day.each do |date, times|
          table.add_separator
          table << [date]
          table.add_separator
          print_day(times).each { |row| table << row }
          table.add_separator
        end
      end
    end

    private

    def colorize(project)
      Rainbow(project).color(COLORS[project.chars.map(&:ord).reduce(:+) % COLORS.size])
    end

    def print_day(times)
      times.sort_by { |log| log[:project] }.flat_map do |log|
        lines = [[colorize(log[:project]), log[:branch], format_time(log[:time])]]
        lines << ['', Rainbow(log[:link]).color(80, 80, 80), ''] if log[:link]
        lines
      end
    end
  end
end
