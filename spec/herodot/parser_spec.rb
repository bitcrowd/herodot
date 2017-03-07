require 'spec_helper'

RSpec.describe Herodot::Parser do
  let(:fixture_path) { "#{Dir.pwd}/spec/fixtures/" }
  let(:config) { Herodot::Configuration.new(worklog) }
  let(:now) { Time.local(2017, 3, 7, 12, 0) }

  before do
    allow(Time).to receive(:now).and_return(now)
    allow(config).to receive(:projects_directory) { '/Users/me/projects/' }
  end

  context '.parse' do
    subject(:parsed_worklog) { described_class.parse(Time.local(2017, 3, 7, 0, 0), config) }
    subject(:found_ids) { parsed_worklog.logs_with_times.map { |log| log[:id] } }
    let(:worklog) { "#{fixture_path}/worklog_before_lunch" }
    before do
      allow(File).to receive(:exist?).with(Herodot::Configuration::CONFIG_FILE).and_return(false)
    end

    let(:expected_worklog) do
      {
        'example:some-branch'                 => { time: 1.0,
                                                   branch: 'some-branch',
                                                   project: 'example' },
        'example:bug/EXAM-2-some-bug'         => { time: 707.0,
                                                   branch: 'bug/EXAM-2-some-bug',
                                                   project: 'example' },
        'example:feature/EXAM-1-some-feature' => { time: 4690.0,
                                                   branch: 'feature/EXAM-1-some-feature',
                                                   project: 'example' }
      }
    end

    it 'parses example worklog (before lunch)' do
      expect(found_ids).not_to include(:lunch_break_start, :lunch_break_end)
      expect(parsed_worklog.totals).to eq [[Date.new(2017, 3, 7), expected_worklog]]
    end
  end
end
