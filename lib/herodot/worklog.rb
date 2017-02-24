require 'csv'
require 'chronic'
require 'terminal-table'

module Herodot
  class Worklog
    EVENTS = [:work_start, :work_end, :lunch_break_start,
              :lunch_break_end, :before_first_dates_start,
              :after_last_dates_end].freeze

    HEADERS = %w(Project Branch Time).freeze

    def list
      user_path =  File.expand_path('~').to_s
      ignored_path = user_path
      logs = []
      dates = []
      logs << { time: Time.new(0), id: :before_first_dates_start }

      CSV.foreach("#{user_path}/worklog", col_sep: ';') do |row|
        time = Time.parse(row[0])
        dates << time.to_date
        logs << {
          time: time,
          id: "#{row[1]}:#{row[2]}",
          branch: row[2],
          project: row[1].gsub(ignored_path, '')
        }
      end
      logs << { time: Time.now, id: :after_last_dates_end }

      filtered_logs = logs.reject { |l| l[:branch] == 'HEAD' }
                          .chunk { |x| x[:id] }.map(&:last).map(&:first)

      dates.uniq.each do |date|
        filtered_logs << { time: Time.new("#{date} 10:00"), id: :work_start }
        filtered_logs << { time: Time.new("#{date} 13:00"), id: :lunch_break_start }
        filtered_logs << { time: Time.new("#{date} 13:00"), id: :lunch_break_end }
        filtered_logs << { time: Time.new("#{date} 18:00"), id: :work_end }
      end

      sorted_filtered_logs = filtered_logs.sort_by { |log| log[:time] }

      logs_with_times = sorted_filtered_logs.each_cons(2).map do |log, following_log|
        following_log[:id_before] = log[:id] if EVENTS.include? following_log[:id]
        id = EVENTS.include?(log[:id]) ? log[:id_before] : log[:id]
        log.merge id: id,
                  time: (following_log[:time] - log[:time]),
                  date: log[:time].to_date
      end

      grouped = logs_with_times.group_by { |time| time[:date] }
      dates.uniq.each do |date|
        times = grouped[date]
        puts '-------------------------'
        puts "Logs for #{date}"
        puts '-------------------------'
        table = Terminal::Table.new(headings: HEADERS) do |table|
          times.each do |time|
            table << [time[:project], time[:branch], time[:time]]
          end
        end
        # puts table
        time_sums = times.each_with_object({}) do |time, sums|
          sums[time[:id]] ||= { time: 0, project: time[:project], branch: time[:branch] }
          sums[time[:id]][:time] += time[:time]
        end
        puts 'TOTALS'
        table = Terminal::Table.new(headings: HEADERS) do |table|
          time_sums.each do |id, hash|
            next if EVENTS.include?(id)
            total_seconds = hash[:time].to_i
            seconds = total_seconds % 60
            minutes = (total_seconds / 60) % 60
            hours = total_seconds / (60 * 60)
            time = "#{hours}:#{minutes.to_s.rjust(2, '0')}:#{seconds.to_s.rjust(2, '0')}"
            table << [hash[:project], hash[:branch], time]
          end
        end
        puts table
      end
    end
  end
end
