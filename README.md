# Switches

## Description

Switches provides for a nice wrapper to OptionParser to also act as a store for switches supplied.

## Installation

Add this line to your application's Gemfile:

	gem 'switches'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install switches


## Usage

```Ruby

# With optional switch

switches = Switches.new do |s|
  s.set(:a)
  # OR
  s.optional(:a)
end
switches.a

# With argument required

switches = Switches.new do |s|
  s.set!(:a)
  # OR
  s.optional!(:a)
end
switches.a

# With switch required

switches = Switches.new do |s|
  s.set(:a, required: true)
  # OR
  s.required(:a)
end
switches.a

# With switch and argument required

switches = Switches.new do |s|
  s.set!(:a, required: true)
  # OR
  s.required!(:a)
end
switches.a

# With boolean switch

switches = Switches.new do |s|
  s.set(:a?)
  # OR
  s.boolean(:a)
end
switches.a?

# With a default value

switches = Switches.new do |s|
  s.set(:a, default: 31)
end
switches.a # => 31

# With switch cast to an integer

switches = Switches.new(include_casting_interface_methods: true) do |s|
  s.set(:a, cast: Integer)
  # OR
  s.set(:a, type: Integer)
  # OR
  s.set(:a, class: Integer)
  # OR
  s.integer(:a)
end
switches.a.class # => Integer

# With switch cast to a float

switches = Switches.new(include_casting_interface_methods: true) do |s|
  s.set(:a, cast: Float)
  # OR
  s.set(:a, type: Float)
  # OR
  s.set(:a, class: Float)
  # OR
  s.float(:a)
end
switches.a.class # => Float

# With switch cast to an array

switches = Switches.new(include_casting_interface_methods: true) do |s|
  s.set(:a, cast: Array)
  # OR
  s.set(:a, type: Array)
  # OR
  s.set(:a, class: Array)
  # OR
  s.float(:a)
end
switches.a.class # => Array

# With switch cast to a regex

switches = Switches.new(include_casting_interface_methods: true) do |s|
  s.set(:a, cast: Regexp)
  # OR
  s.set(:a, type: Regexp)
  # OR
  s.set(:a, class: Regexp)
  # OR
  s.regexp(:a)
end
switches.a.class # => Regexp

# With a default value and cast to an integer

switches = Switches.new(include_casting_interface_methods: true) do |s|
  s.set(:a, default: 31, cast: Integer)
  # OR
  s.set(:a, default: 31, type: Integer)
  # OR
  s.set(:a, default: 31, class: Integer)
  # OR
  s.integer(:a, default: 31)
end
switches.a # => 31 if no argument supplied
switches.a.class # => Integer

# With a description of the switch

switches = Switches.new do |s|
  s.set(:a){'This is the -a switch.'}
end

# With a banner

switches = Switches.new do |s|
  s.banner = 'Here is a banner for the switches.'
end

# Return a hash instead of an object of class Switches

switches = Switches.new(to_h: true) do |s|
  s.set(:a)
end
# OR
switches = Switches.as_h do |s|
  s.set(:a)
end

switches[:a]
switches.class # => Hash

# Without a block

switches = Switches.new
switches.set(:a)
switches.parse!
switches.a

# With an action

switches = Switches.new do |s|
switches.perform(:a){puts 'a'}
switches.parse! # => a

# With an action uses the argument

switches = Switches.new do |s|
switches.perform(:a){|block_arg| puts block_arg.upcase}
switches.parse! # => A

# With multiple features combined

switches = Switches.new(include_casting_interface_methods: true, to_h: true) do |s|
  s.set(:a, default: 31, cast: Integer){'This is the switch -a.  It has a default of 31.'}
  # OR
  s.set(:a, default: 31, type: Integer){'This is the switch -a.  It has a default of 31.'}
  # OR
  s.set(:a, default: 31, class: Integer){'This is the switch -a.  It has a default of 31.'}
  # OR
  s.integer(:a, default: 31){'This is the switch -a.  It has a default of 31.'}
end
switches[:a] # => 31 if no argument supplied
switches.a.class # => Integer
switches.class # => Hash

```

## Contributing

1. Fork it ( https://github.com/thoran/HTTP/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new pull request
