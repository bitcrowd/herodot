module Herodot
  class Worklog
    attr_reader :branches
    END_TRACK_EVENTS = %i[work_end lunch_break_start after_last_dates_end].freeze
    START_TRACK_EVNETS = %i[work_start lunch_break_end before_first_dates_start].freeze
    EVENTS = (END_TRACK_EVENTS + START_TRACK_EVNETS).freeze

    def initialize(config)
      @raw_logs = []
      @branches = {}
      @dates = []
      @config = config
    end

    def add_entry(time, project_path, branch)
      return if project_path.nil?
      project = project_path.gsub(@config.projects_directory.to_s, '')
      id = "#{project}:#{branch}"
      @raw_logs << { time: time, id: id }
      @branches[id] = { branch: branch, project: project, path: project_path }
    end

    def logs_with_events
      filtered_logs = @raw_logs.chunk { |x| x[:id] }.map(&:last).map(&:first)
      filtered_logs += work_time_events
      filtered_logs << { time: Time.new(0), id: :before_first_dates_start }
      filtered_logs << { time: Time.now, id: :after_last_dates_end }
      filtered_logs.sort_by { |log| log[:time] }
    end

    def logs_with_times
      current_id = nil
      logs_with_events.each_cons(2).map do |log, following_log|
        current_id = log[:id] unless EVENTS.include?(log[:id])
        log.merge id: actual_id(current_id, log[:id]),
                  time: time_between(log, following_log),
                  date: log[:time].to_date
      end
    end

    def logs_with_times_cleaned
      logs_with_times.reject { |log| EVENTS.include?(log[:id]) }
    end

    def totals
      grouped = logs_with_times_cleaned.group_by { |time| time[:date] }
      dates.map do |date|
        time_sums = grouped[date].each_with_object({}) do |time, sums|
          id = time[:id]
          sums[id] ||= { time: 0, **branch(id) }
          sums[id][:time] += time[:time]
        end
        [date, time_sums.values]
      end
    end

    def branch(id)
      @branches.fetch(id, {})
    end

    def dates
      @raw_logs.map { |log| log[:time].to_date }.uniq.sort
    end

    def work_time_events
      dates.flat_map do |date|
        @config.work_times.map { |event, (hour, minute)|
          time = Time.new(date.year, date.month, date.day, hour, minute)
          next if time > Time.now
          { id: event, time: time }
        }.compact
      end
    end

    def same_date?(log_entry, other_log_entry)
      log_entry[:time].to_date == other_log_entry[:time].to_date
    end

    def time_between(log_entry, following_entry)
      return 0 unless same_date?(log_entry, following_entry)
      following_entry[:time] - log_entry[:time]
    end

    def actual_id(current_id, id)
      END_TRACK_EVENTS.include?(id) ? id : current_id || id
    end
  end
end
