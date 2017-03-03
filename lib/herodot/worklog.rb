class Herodot::Worklog
  attr_reader :branches
  END_TRACK_EVENTS = [:work_end, :lunch_break_start, :after_last_dates_end].freeze
  START_TRACK_EVNETS = [:work_start, :lunch_break_end, :before_first_dates_start].freeze
  EVENTS = (END_TRACK_EVENTS + START_TRACK_EVNETS).freeze

  def initialize
    @raw_logs = []
    @branches = {}
    @dates = []
  end

  def add_entry(time, project, branch)
    id = "#{project}:#{branch}"
    @raw_logs << { time: time, id: id }
    @branches[id] = { branch: branch, project: project }
  end

  def logs_with_events
    filtered_logs = @raw_logs.chunk { |x| x[:id] }.map(&:last).map(&:first)

    dates.each do |date|
      filtered_logs << { time: Time.new(date.year, date.month, date.day, 9, 30), id: :work_start }
      filtered_logs << { time: Time.new(date.year, date.month, date.day, 13, 0), id: :lunch_break_start }
      filtered_logs << { time: Time.new(date.year, date.month, date.day, 13, 30), id: :lunch_break_end }
      filtered_logs << { time: Time.new(date.year, date.month, date.day, 18, 0), id: :work_end }
    end

    filtered_logs << { time: Time.new(0), id: :before_first_dates_start }
    filtered_logs << { time: Time.now, id: :after_last_dates_end }
    filtered_logs.sort_by { |log| log[:time] }
  end

  def logs_with_times
    current_id = nil
    times = logs_with_events.each_cons(2).map do |log, following_log|
      current_id = log[:id] unless EVENTS.include?(log[:id])
      log.merge id: actual_id(current_id, log[:id]),
                time: time_between(log, following_log),
                date: log[:time].to_date
    end
    times.reject { |log| EVENTS.include?(log[:id]) }
  end

  def totals
    grouped = logs_with_times.group_by { |time| time[:date] }
    dates.map do |date|
      time_sums = grouped[date].each_with_object({}) do |time, sums|
        id = time[:id]
        sums[id] ||= { time: 0, project: @branches.dig(id, :project), branch: @branches.dig(id, :branch) }
        sums[id][:time] += time[:time]
      end
      [date, time_sums]
    end
  end

  def dates
    @raw_logs.map { |log| log[:time].to_date }.uniq.sort
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
