require 'csv'
require 'pry'

class Herodot::Parser
  class << self
    def parse(range, config)
      worklog = Herodot::Worklog.new(config)
      from, to = from_to_from_range(range)
      CSV.foreach(config.worklog_file, col_sep: ';') do |row|
        next if row[2] == 'HEAD'
        time = Time.parse(row[0])
        worklog.add_entry(time, row[1], row[2]) if time >= from && time <= to
      end
      worklog
    end

    def from_to_from_range(range)
      return [range, Time.now] unless range.respond_to?(:begin) && range.respond_to?(:end)
      [range.begin, range.end + 3600]
    end
  end
end
