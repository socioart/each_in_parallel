# EachInParallel

`each` in multi threads and/or multi process.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'each_in_parallel', git: "https://github.com/socioart/each_in_parallel.git"
```

And then execute:

    $ bundle

## Usage

Pass enumerable and block. The block will execute in parallel for each item.
Enumeration is executed lazily.

```ruby
begin
  EachInParallel.each_in_threads(1..) {|n| raise StopIteration if n > 10 }
rescue StopIteration
end

begin
  EachInParallel.each_in_processes(1..) {|n| raise StopIteration if n > 10 }
rescue StopIteration
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/labocho/each_in_parallel.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
