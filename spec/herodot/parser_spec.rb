require 'spec_helper'

RSpec.describe Herodot::Parser do
  let(:fixture_path) { "#{Dir.pwd}/spec/fixtures/" }
  let(:config) { Herodot::Configuration.new(worklog) }

  before do
    allow(Time).to receive(:now).and_return(now)
    allow(config).to receive(:projects_directory) { '/Users/me/projects/' }
  end

  context '.parse' do
    subject(:parsed_worklog) { described_class.parse(time, config) }

    before do
      allow(File).to receive(:exist?).with(Herodot::Configuration::CONFIG_FILE).and_return(false)
    end

    context 'parse a worklog with multiple days' do
      let(:days) { parsed_worklog.totals.map(&:first) }

      let(:logs) { parsed_worklog.totals }

      subject(:total_time_in_hours_per_day) do
        logs.map { |_, logs_day| (logs_day.reduce(0) { |sum, log| sum + log[:time] } / 3600) }
      end

      let(:now) { Time.local(2017, 3, 7, 12, 0) }
      let(:time) do
        instance_double(Chronic::Span, begin:  Time.local(2017, 2, 27, 12, 0),
                                       end:  Time.local(2017, 3, 5, 12, 0))
      end
      let(:worklog) { "#{fixture_path}/worklog_example" }

      it 'parses a worklog for multiple days' do
        expect(days.size).to eq 5
        days.each { |day| expect(day).to be_a Date }
      end

      it 'calculates the hours of a day up to a total of 8 hours' do
        # The first day is not complete and the second last day has obvious over hours
        expect(total_time_in_hours_per_day).to eq [1.4105555555555556, 8, 8, 8.47888888888889, 8]
      end

      let(:project_a_path) do
        { project: 'project_a/repository', path: '/Users/me/projects/project_a/repository' }
      end

      let(:expected_branches) do
        [{ branch: 'master', **project_a_path },
         { branch: 'feature/FEAT-555-some-other-feature', **project_a_path },
         { branch: 'staging', **project_a_path },
         { branch: 'feature/FEAT-444-an-awesome-feature', **project_a_path },
         { branch: 'feature/FEAT-312-smaller-feature', **project_a_path },
         { branch: 'test', project: 'herodot', path: '/Users/me/projects/herodot' },
         { branch: 'master', project: 'herodot', path: '/Users/me/projects/herodot' },
         { branch: 'master', project: 'bitcrowd/herodot', path: '/Users/me/projects/bitcrowd/herodot' },
         { branch: 'feature/FEAT-4321-some-feature-2', **project_a_path },
         { branch: 'production', **project_a_path }]
      end

      it 'extracts the right branches' do
        expect(parsed_worklog.branches.values).to eq expected_branches
      end

      context 'with a folder that is not in the projects directory in the worklog' do
        let(:time) do
          instance_double(Chronic::Span, begin:  Time.local(2017, 3, 6, 0, 0),
                                         end:  Time.local(2017, 3, 6, 23, 0))
        end

        it 'uses the full path there' do
          expect(parsed_worklog.totals.first.last)
            .to include(time: 17_157.0,
                        branch: 'in-another-branch',
                        project: '/another-project/in-some-nested-folder/888',
                        path: '/another-project/in-some-nested-folder/888')
        end
      end
    end

    context 'look at worklog before lunch' do
      subject(:found_ids) { parsed_worklog.logs_with_times.map { |log| log[:id] } }

      let(:now) { Time.local(2017, 3, 7, 12, 0) }
      let(:time) { Time.local(2017, 3, 7, 0, 0) }
      let(:worklog) { "#{fixture_path}/worklog_before_lunch" }
      let(:expected_worklog) do
        [
          { time: 1.0, branch: 'some-branch',
            project: 'example', path: '/Users/me/projects/example' },
          { time: 707.0, branch: 'bug/EXAM-2-some-bug',
            project: 'example', path: '/Users/me/projects/example' },
          { time: 4690.0, branch: 'feature/EXAM-1-some-feature',
            project: 'example', path: '/Users/me/projects/example' }
        ]
      end

      it 'parses example worklog (before lunch)' do
        expect(found_ids).not_to include(:lunch_break_start, :lunch_break_end)
        expect(parsed_worklog.totals).to eq [[Date.new(2017, 3, 7), expected_worklog]]
      end
    end
  end
end
