# Herodot

[![Build Status](https://travis-ci.org/bitcrowd/herodot.svg?branch=master)](https://travis-ci.org/bitcrowd/herodot)

Tracks your work based on git branch checkouts and commits. With herodot every time you switch branches or commit into a branch,
the brach name, time and project is logged into a worklog file. Herodot can then parse that worklog file and show you a *rough
estimate* on which branch in which folder you worked on and how long. This can aid you with your personal time tracking.

## Installation

Install with:

    $ gem install herodot

## Usage

Track a git repository:

    $ herodot track [path=.]


Show your worklogs this week:

    $ herodot show

    or shorter

    $ herodot

Show last week

    $ herodot show last week

Show worklogs from 19-12-2016

    $ herodot show 19-12-2016

Herodot uses Chronic (https://github.com/mojombo/chronic) under the hood so you can enter anything that chronic supports.

Instead of a terminal table you can also output into the `json` format:

    $ herodot show -f json
    $ herodot show -f json last week
    $ herodot show --format json last week

Show Help:

    $ herodot help
    $ herodot help track
    $ herodot help show

## Configuration

Herodot writes a configuration yaml to `~/.herodot.yml` with something like this:

```
---
projects_directory: "~" # Directory where you checkout your projects. Used to shorten paths
work_times:             # Your work times that are used for guessing the times.
  work_start: '9:30'
  lunch_break_start: '13:00'
  lunch_break_end: '13:30'
  work_end: '18:00'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bitcrowd/herodot.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
