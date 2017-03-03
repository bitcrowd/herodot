require 'terminal-table'

class Herodot::Table
  HEADERS = %w(Project Branch Time).freeze

  def self.format_time(time_is_seconds)
    total_seconds = time_is_seconds.to_i
    seconds = total_seconds % 60
    minutes = (total_seconds / 60) % 60
    hours = total_seconds / (60 * 60)
    "#{hours}:#{minutes.to_s.rjust(2, '0')}:#{seconds.to_s.rjust(2, '0')}"
  end

  def self.print(worklogs_totals_per_day)
    Terminal::Table.new(headings: HEADERS) do |table|
      worklogs_totals_per_day.each do |date, time_sums|
        table.add_separator
        table << [date]
        table.add_separator
        time_sums.each do |id, hash|
          table << [hash[:project] || id || '-', hash[:branch] || '-', format_time(hash[:time])]
        end
      end
    end
  end
end
