# test/switches_test.rb

require 'minitest/autorun'

require_relative '../lib/switches'

describe Switches do
  describe ".new" do
    it "returns an object of class Switches" do
      _(Switches.new.class).must_equal Switches
    end
  end

  describe "#set" do
    def build(switches_string = '')
      ARGV.clear
      switches_string.split.each{|a| ARGV << a}
      Switches.new do |s|
        s.set :v?, :verbose?
        s.set :p, :port
        s.set :host, :h
      end
    end

    it "sets a short boolean switch to true when supplied with a short switch" do
      _(build('-v').v?).must_equal true
    end

    it "sets a long boolean switch to true when supplied with a short switch" do
      _(build('-v').verbose?).must_equal true
    end

    it "sets a short boolean switch to true when supplied with a long switch" do
      _(build('--verbose').v?).must_equal true
    end

    it "sets a long boolean switch to true when supplied with a long switch" do
      _(build('--verbose').verbose?).must_equal true
    end

    it "sets a short switch to the value supplied when supplied with a short switch" do
      _(build('-p 22').p).must_equal '22'
    end

    it "sets a long switch to the value supplied when supplied with a short switch" do
      _(build('-p 22').port).must_equal '22'
    end

    it "sets a short switch to the value supplied when supplied with a long switch" do
      _(build('--port 22').p).must_equal '22'
    end

    it "sets a long switch to the value supplied when supplied with a long switch" do
      _(build('--port 22').port).must_equal '22'
    end

    it "doesn't matter in which order the short and long switches are given" do
      _(build('-h example.com').h).must_equal 'example.com'
      _(build('--host example.com').h).must_equal 'example.com'
    end
  end

  describe "#set!" do
    def build(switches_string = '')
      ARGV.clear
      switches_string.split.each{|a| ARGV << a}
      Switches.new do |s|
        s.set! :p, :port
      end
    end

    it "sets a short switch to the argument supplied with a short switch" do
      _(build('-p 22').p).must_equal '22'
    end

    it "sets a long switch to the argument supplied with a short switch" do
      _(build('-p 22').port).must_equal '22'
    end

    it "sets a short switch to the argument supplied with a long switch" do
      _(build('--port 22').p).must_equal '22'
    end

    it "sets a long switch to the argument supplied with a long switch" do
      _(build('--port 22').port).must_equal '22'
    end

    it "raises OptionParser::MissingArgument when no argument is supplied to a short switch" do
      _{build('-p')}.must_raise OptionParser::MissingArgument
    end

    it "raises OptionParser::MissingArgument when no argument is supplied to a long switch" do
      _{build('--port')}.must_raise OptionParser::MissingArgument
    end
  end

  describe "#required" do
    def build(switches_string = '')
      ARGV.clear
      switches_string.split.each{|a| ARGV << a}
      Switches.new do |s|
        s.required :p, :port
      end
    end

    it "sets a short switch to the argument supplied with a short switch" do
      _(build('-p 22').p).must_equal '22'
    end

    it "sets a long switch to the argument supplied with a short switch" do
      _(build('-p 22').port).must_equal '22'
    end

    it "sets a short switch to the argument supplied with a long switch" do
      _(build('--port 22').p).must_equal '22'
    end

    it "sets a long switch to the argument supplied with a long switch" do
      _(build('--port 22').port).must_equal '22'
    end

    it "raises RequiredSwitchMissing when no switch is supplied" do
      _{build}.must_raise RequiredSwitchMissing
    end

    it "names every missing switch in the RequiredSwitchMissing message" do
      error = _{build}.must_raise RequiredSwitchMissing
      _(error.message).must_match(/-p.*--port/m)
    end
  end

  describe "#required!" do
    def build(switches_string = '')
      ARGV.clear
      switches_string.split.each{|a| ARGV << a}
      Switches.new do |s|
        s.required! :p, :port
      end
    end

    it "sets a short switch to the argument supplied with a short switch" do
      _(build('-p 22').p).must_equal '22'
    end

    it "sets a long switch to the argument supplied with a short switch" do
      _(build('-p 22').port).must_equal '22'
    end

    it "sets a short switch to the argument supplied with a long switch" do
      _(build('--port 22').p).must_equal '22'
    end

    it "sets a long switch to the argument supplied with a long switch" do
      _(build('--port 22').port).must_equal '22'
    end

    it "raises OptionParser::MissingArgument when no argument is supplied to a short switch" do
      _{build('-p')}.must_raise OptionParser::MissingArgument
    end

    it "raises OptionParser::MissingArgument when no argument is supplied to a long switch" do
      _{build('--port')}.must_raise OptionParser::MissingArgument
    end

    it "raises RequiredSwitchMissing when no switch is supplied" do
      _{build}.must_raise RequiredSwitchMissing
    end
  end

  describe "switch names which collide with a method" do
    def build(&block)
      ARGV.clear
      Switches.new(&block)
    end

    it "refuses a switch named after a core method" do
      error = _{build{|s| s.set(:tap)}}.must_raise SwitchNameCollision
      _(error.message).must_match(/Kernel#tap/)
    end

    it "refuses a switch named after a Switches method" do
      error = _{build{|s| s.set(:settings)}}.must_raise SwitchNameCollision
      _(error.message).must_match(/Switches#settings/)
    end

    it "refuses a colliding name declared through #perform" do
      _{build{|s| s.perform(:display){}}}.must_raise SwitchNameCollision
    end

    it "names the switch in the form it would be supplied in" do
      error = _{build{|s| s.set(:instance_variable_get)}}.must_raise SwitchNameCollision
      _(error.message).must_match(/--instance_variable_get/)
    end

    it "raises before the switch is declared to the parser" do
      switches = Switches.new
      begin; switches.set(:tap); rescue SwitchNameCollision; end
      _(switches.to_h).must_equal({})
    end

    it "accepts the name as a boolean, the accessor then carrying a question mark" do
      ARGV.clear
      ARGV << '--tap'
      _(Switches.new{|s| s.boolean(:tap)}.tap?).must_equal true
    end

    it "accepts a name OptionParser has, a declared switch winning over the parser" do
      ARGV.clear
      %w{--banner text}.each{|a| ARGV << a}
      _(Switches.new{|s| s.set(:banner)}.banner).must_equal 'text'
    end

    it "raises a SwitchNameCollision, which is an ArgumentError" do
      _(SwitchNameCollision.ancestors).must_include ArgumentError
    end
  end

  describe "OptionParser methods" do
    def build(&block)
      ARGV.clear
      Switches.new(&block)
    end

    it "forwards a writer to the OptionParser" do
      _(build{|s| s.banner = 'Usage: tap-audit [options]'}.help).must_match(/\AUsage: tap-audit \[options\]/)
    end

    it "forwards a method taking an argument to the OptionParser" do
      _(build{|s| s.separator 'Options:'}.help).must_match(/^Options:$/)
    end

    it "forwards a reader to the OptionParser" do
      switches = build{|s| s.program_name = 'tap-audit'}
      _(switches.program_name).must_equal 'tap-audit'
      _(switches.help).must_match(/\AUsage: tap-audit/)
    end

    it "prefers a declared switch to the OptionParser method of the same name" do
      ARGV.clear
      %w{--version 2.1}.each{|a| ARGV << a}
      _(Switches.new{|s| s.set(:version)}.version).must_equal '2.1'
    end

    it "prefers a declared switch when it is written to as well" do
      switches = build{|s| s.set(:banner)}
      switches.banner = 'a setting, not the banner'
      _(switches.to_h[:banner]).must_equal 'a setting, not the banner'
    end

    it "falls through to the settings for a name which is neither" do
      _(build{|s| s.set(:port)}.nonesuch).must_be_nil
    end

    it "does not forward #to_a, which OptionParser answers with its help" do
      _(build{|s| s.set(:port)}.to_a).must_be_nil
    end

    it "leaves Array() with the switches rather than the parser's help" do
      switches = build{|s| s.set(:port)}
      _(Array(switches)).must_equal [switches]
    end

    it "leaves the splat with the switches rather than the parser's help" do
      switches = build{|s| s.set(:port)}
      _([*switches]).must_equal [switches]
    end
  end

  describe "multi-word switches" do
    def build(switches_string = '')
      ARGV.clear
      switches_string.split.each{|a| ARGV << a}
      Switches.new do |s|
        s.boolean :update_template
        s.set :access_token
      end
    end

    it "sets a boolean switch supplied in its underscored form" do
      _(build('--update_template').update_template?).must_equal true
    end

    it "sets a boolean switch supplied in its hyphenated form" do
      _(build('--update-template').update_template?).must_equal true
    end

    it "sets a switch to the argument supplied in its underscored form" do
      _(build('--access_token abc123').access_token).must_equal 'abc123'
    end

    it "sets a switch to the argument supplied in its hyphenated form" do
      _(build('--access-token abc123').access_token).must_equal 'abc123'
    end

    it "names the setting for the symbol declared, whichever form is supplied" do
      _(build('--update-template --access-token abc123').to_h).must_equal({update_template?: true, access_token: 'abc123'})
    end
  end

  describe "multi-word switches with a required argument" do
    def build(switches_string = '')
      ARGV.clear
      switches_string.split.each{|a| ARGV << a}
      Switches.new do |s|
        s.set! :access_token
      end
    end

    it "sets the switch to the argument supplied in its underscored form" do
      _(build('--access_token abc123').access_token).must_equal 'abc123'
    end

    it "sets the switch to the argument supplied in its hyphenated form" do
      _(build('--access-token abc123').access_token).must_equal 'abc123'
    end

    it "raises OptionParser::MissingArgument when no argument is supplied to the underscored form" do
      _{build('--access_token')}.must_raise OptionParser::MissingArgument
    end

    it "raises OptionParser::MissingArgument when no argument is supplied to the hyphenated form" do
      _{build('--access-token')}.must_raise OptionParser::MissingArgument
    end
  end

  describe "multi-word required switches" do
    def build(switches_string = '')
      ARGV.clear
      switches_string.split.each{|a| ARGV << a}
      Switches.new do |s|
        s.required :access_token
      end
    end

    it "counts the underscored form as supplied" do
      _(build('--access_token abc123').access_token).must_equal 'abc123'
    end

    it "counts the hyphenated form as supplied" do
      _(build('--access-token abc123').access_token).must_equal 'abc123'
    end

    it "raises RequiredSwitchMissing when neither form is supplied" do
      _{build}.must_raise RequiredSwitchMissing
    end

    it "names the hyphenated form in the RequiredSwitchMissing message" do
      error = _{build}.must_raise RequiredSwitchMissing
      _(error.message).must_match(/--access-token/)
    end
  end

  describe "#perform" do
    def build(switches_string = '', &block)
      ARGV.clear
      switches_string.split.each{|a| ARGV << a}
      Switches.new{|s| s.perform(:a, :action, &block)}
    end

    it "calls the block when supplied with a short switch" do
      called = false
      build('-a'){called = true}
      _(called).must_equal true
    end

    it "calls the block when supplied with a long switch" do
      called = false
      build('--action'){called = true}
      _(called).must_equal true
    end

    it "doesn't call the block when the switch isn't supplied" do
      called = false
      build{called = true}
      _(called).must_equal false
    end

    it "doesn't require an argument" do
      _(build('-a'){}).must_be_kind_of Switches
    end
  end

  describe "#perform!" do
    def build(switches_string = '', &block)
      ARGV.clear
      switches_string.split.each{|a| ARGV << a}
      Switches.new{|s| s.perform!(:a, :action, &block)}
    end

    it "passes the argument to the block when supplied with a short switch" do
      argument = nil
      build('-a value'){|o| argument = o}
      _(argument).must_equal 'value'
    end

    it "passes the argument to the block when supplied with a long switch" do
      argument = nil
      build('--action value'){|o| argument = o}
      _(argument).must_equal 'value'
    end

    it "doesn't call the block when the switch isn't supplied" do
      called = false
      build{called = true}
      _(called).must_equal false
    end

    it "raises OptionParser::MissingArgument when no argument is supplied" do
      _{build('-a'){}}.must_raise OptionParser::MissingArgument
    end
  end
  describe "a default upon a switch which casts" do
    def build(switches_string = '')
      ARGV.clear
      switches_string.split.each{|a| ARGV << a}
      Switches.new do |s|
        s.integer!(:lines, default: '10')
        s.float!(:ratio, default: '1.5')
        s.array!(:hosts, default: ['a', 'b'])
        s.regexp!(:pattern, default: 'ab+c')
        s.optional!(:mailbox, default: 'INBOX')
      end
    end

    it "casts an integer default rather than answering nil" do
      _(build.lines).must_equal 10
    end

    it "casts a float default rather than answering nil" do
      _(build.ratio).must_equal 1.5
    end

    it "carries an array default rather than answering nil" do
      _(build.hosts).must_equal ['a', 'b']
    end

    it "casts a regexp default rather than answering nil" do
      _(build.pattern).must_equal(/ab+c/)
    end

    it "leaves a default upon a switch which does not cast alone" do
      _(build.mailbox).must_equal 'INBOX'
    end

    it "prefers a supplied value to the default" do
      _(build('--lines 3').lines).must_equal 3
    end
  end
end
