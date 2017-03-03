require 'terminal-table'

class Herodot::Table
  HEADERS = %w(Project Branch Time).freeze

  class << self
    def format_time(time_is_seconds)
      total_seconds = time_is_seconds.to_i
      seconds = total_seconds % 60
      minutes = (total_seconds / 60) % 60
      hours = total_seconds / (60 * 60)
      "#{hours}:#{minutes.to_s.rjust(2, '0')}:#{seconds.to_s.rjust(2, '0')}"
    end

    def print(worklogs_totals_per_day)
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

    def print_day(times)
      times.values.group_by { |log| log[:project] }.flat_map do |_, logs|
        logs.map do |log|
          [log[:project], log[:branch], format_time(log[:time])]
        end
      end
    end
  end
end
