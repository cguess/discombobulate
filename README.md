# Decombobulate

This gem takes a JSON object and converts it to a CSV file automatically and is *very* opinionated (for now).

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add decombobulate

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install decombobulate

## Usage

`decombobulate_object = Decombobulate.new(json)` Note that this takes either a string of json text or a hash/array of parsed data
`decombobulate_objecxt.to_csv` returns a string of CSV data
`decombobulate_objecxt.headers` returns an array of the headers for the CSV file
`decombobulate_objecxt.rows` returns an array of the rows for the CSV file

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cguess/decombobulate. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/cguess/decombobulate/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Decombobulate project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/cguess/decombobulate/blob/master/CODE_OF_CONDUCT.md).
