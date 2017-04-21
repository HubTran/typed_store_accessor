# TypedStoreAccessor

TypedStoreAccessor makes typed accessors with defaults for hash-like db columns easier.

HT to [John Richardson](https://github.com/barooo) for doing most of the actual work.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'typed_store_accessor'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install typed_store_accessor

## Usage

```
Class MyObject
  include TypedStoreAccessor

  typed_store_accessor :settings, :boolean, :test_thing
  typed_store_accessor :settings, :boolean, :test_thing_default, true
  typed_store_accessor :settings, :non_blank_string, :string_thing
  typed_store_accessor :settings,
                       :restricted_string,
                       :restricted_string_thing,
                       "default",
                       values: ["defined_value", "default"]
  typed_store_accessor :settings, :array, :array_thing
  typed_store_accessor :settings, :float, :float_thing
  typed_store_accessor :settings, :big_decimal, :big_decimal_thing
  typed_store_accessor :settings, :hash, :hash_thing
  typed_store_accessor :settings, :hash, :hash_with_default, {}
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/HubTran/typed_store_accessor.git

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
