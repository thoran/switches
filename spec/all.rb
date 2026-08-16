# spec/all.rb

require_relative '../lib/Switches'

describe Switches do
  describe ".new" do
    it "returns an object of class Switches" do
      expect(Switches.new.class).to eq(Switches)
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
      expect(build('-v').v?).to eq(true)
    end

    it "sets a long boolean switch to true when supplied with a short switch" do
      expect(build('-v').verbose?).to eq(true)
    end

    it "sets a short boolean switch to true when supplied with a long switch" do
      expect(build('--verbose').v?).to eq(true)
    end

    it "sets a long boolean switch to true when supplied with a long switch" do
      expect(build('--verbose').verbose?).to eq(true)
    end

    it "sets a short switch to the value supplied when supplied with a short switch" do
      expect(build('-p 22').p).to eq('22')
    end

    it "sets a long switch to the value supplied when supplied with a short switch" do
      expect(build('-p 22').port).to eq('22')
    end

    it "sets a short switch to the value supplied when supplied with a long switch" do
      expect(build('--port 22').p).to eq('22')
    end

    it "sets a long switch to the value supplied when supplied with a long switch" do
      expect(build('--port 22').port).to eq('22')
    end

    it "doesn't matter in which order the short and long switches are given" do
      expect(build('-h example.com').h).to eq('example.com')
      expect(build('--host example.com').h).to eq('example.com')
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
      expect(build('-p 22').p).to eq('22')
    end

    it "sets a long switch to the argument supplied with a short switch" do
      expect(build('-p 22').port).to eq('22')
    end

    it "sets a short switch to the argument supplied with a long switch" do
      expect(build('--port 22').p).to eq('22')
    end

    it "sets a long switch to the argument supplied with a long switch" do
      expect(build('--port 22').port).to eq('22')
    end

    it "raises OptionParser::MissingArgument when no argument is supplied to a short switch" do
      expect{build('-p')}.to raise_error(OptionParser::MissingArgument)
    end

    it "raises OptionParser::MissingArgument when no argument is supplied to a long switch" do
      expect{build('--port')}.to raise_error(OptionParser::MissingArgument)
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
      expect(build('-p 22').p).to eq('22')
    end

    it "sets a long switch to the argument supplied with a short switch" do
      expect(build('-p 22').port).to eq('22')
    end

    it "sets a short switch to the argument supplied with a long switch" do
      expect(build('--port 22').p).to eq('22')
    end

    it "sets a long switch to the argument supplied with a long switch" do
      expect(build('--port 22').port).to eq('22')
    end

    it "raises RequiredSwitchMissing when no switch is supplied" do
      expect{build}.to raise_error(RequiredSwitchMissing)
    end

    it "names every missing switch in the RequiredSwitchMissing message" do
      expect{build}.to raise_error(RequiredSwitchMissing, /-p.*--port/m)
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
      expect(build('-p 22').p).to eq('22')
    end

    it "sets a long switch to the argument supplied with a short switch" do
      expect(build('-p 22').port).to eq('22')
    end

    it "sets a short switch to the argument supplied with a long switch" do
      expect(build('--port 22').p).to eq('22')
    end

    it "sets a long switch to the argument supplied with a long switch" do
      expect(build('--port 22').port).to eq('22')
    end

    it "raises OptionParser::MissingArgument when no argument is supplied to a short switch" do
      expect{build('-p')}.to raise_error(OptionParser::MissingArgument)
    end

    it "raises OptionParser::MissingArgument when no argument is supplied to a long switch" do
      expect{build('--port')}.to raise_error(OptionParser::MissingArgument)
    end

    it "raises RequiredSwitchMissing when no switch is supplied" do
      expect{build}.to raise_error(RequiredSwitchMissing)
    end
  end

  describe "switch names which collide with a method" do
    def build(&block)
      ARGV.clear
      Switches.new(&block)
    end

    it "refuses a switch named after a core method" do
      expect{build{|s| s.set(:tap)}}.to raise_error(SwitchNameCollision, /Kernel#tap/)
    end

    it "refuses a switch named after a Switches method" do
      expect{build{|s| s.set(:settings)}}.to raise_error(SwitchNameCollision, /Switches#settings/)
    end

    it "refuses a colliding name declared through #perform" do
      expect{build{|s| s.perform(:display){}}}.to raise_error(SwitchNameCollision)
    end

    it "names the switch in the form it would be supplied in" do
      expect{build{|s| s.set(:instance_variable_get)}}.to raise_error(SwitchNameCollision, /--instance_variable_get/)
    end

    it "raises before the switch is declared to the parser" do
      switches = Switches.new
      begin; switches.set(:tap); rescue SwitchNameCollision; end
      expect(switches.to_h).to eq({})
    end

    it "accepts the name as a boolean, the accessor then carrying a question mark" do
      ARGV.clear
      ARGV << '--tap'
      expect(Switches.new{|s| s.boolean(:tap)}.tap?).to eq(true)
    end

    it "accepts a name OptionParser has, a declared switch winning over the parser" do
      ARGV.clear
      %w{--banner text}.each{|a| ARGV << a}
      expect(Switches.new{|s| s.set(:banner)}.banner).to eq('text')
    end

    it "raises a SwitchNameCollision, which is an ArgumentError" do
      expect(SwitchNameCollision.ancestors).to include(ArgumentError)
    end
  end

  describe "OptionParser methods" do
    def build(&block)
      ARGV.clear
      Switches.new(&block)
    end

    it "forwards a writer to the OptionParser" do
      expect(build{|s| s.banner = 'Usage: tap-audit [options]'}.help).to match(/\AUsage: tap-audit \[options\]/)
    end

    it "forwards a method taking an argument to the OptionParser" do
      expect(build{|s| s.separator 'Options:'}.help).to match(/^Options:$/)
    end

    it "forwards a reader to the OptionParser" do
      switches = build{|s| s.program_name = 'tap-audit'}
      expect(switches.program_name).to eq('tap-audit')
      expect(switches.help).to match(/\AUsage: tap-audit/)
    end

    it "prefers a declared switch to the OptionParser method of the same name" do
      ARGV.clear
      %w{--version 2.1}.each{|a| ARGV << a}
      expect(Switches.new{|s| s.set(:version)}.version).to eq('2.1')
    end

    it "prefers a declared switch when it is written to as well" do
      switches = build{|s| s.set(:banner)}
      switches.banner = 'a setting, not the banner'
      expect(switches.to_h[:banner]).to eq('a setting, not the banner')
    end

    it "falls through to the settings for a name which is neither" do
      expect(build{|s| s.set(:port)}.nonesuch).to eq(nil)
    end

    it "does not forward #to_a, which OptionParser answers with its help" do
      expect(build{|s| s.set(:port)}.to_a).to eq(nil)
    end

    it "leaves Array() with the switches rather than the parser's help" do
      switches = build{|s| s.set(:port)}
      expect(Array(switches)).to eq([switches])
    end

    it "leaves the splat with the switches rather than the parser's help" do
      switches = build{|s| s.set(:port)}
      expect([*switches]).to eq([switches])
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
      expect(build('--update_template').update_template?).to eq(true)
    end

    it "sets a boolean switch supplied in its hyphenated form" do
      expect(build('--update-template').update_template?).to eq(true)
    end

    it "sets a switch to the argument supplied in its underscored form" do
      expect(build('--access_token abc123').access_token).to eq('abc123')
    end

    it "sets a switch to the argument supplied in its hyphenated form" do
      expect(build('--access-token abc123').access_token).to eq('abc123')
    end

    it "names the setting for the symbol declared, whichever form is supplied" do
      expect(build('--update-template --access-token abc123').to_h).to eq({update_template?: true, access_token: 'abc123'})
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
      expect(build('--access_token abc123').access_token).to eq('abc123')
    end

    it "sets the switch to the argument supplied in its hyphenated form" do
      expect(build('--access-token abc123').access_token).to eq('abc123')
    end

    it "raises OptionParser::MissingArgument when no argument is supplied to the underscored form" do
      expect{build('--access_token')}.to raise_error(OptionParser::MissingArgument)
    end

    it "raises OptionParser::MissingArgument when no argument is supplied to the hyphenated form" do
      expect{build('--access-token')}.to raise_error(OptionParser::MissingArgument)
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
      expect(build('--access_token abc123').access_token).to eq('abc123')
    end

    it "counts the hyphenated form as supplied" do
      expect(build('--access-token abc123').access_token).to eq('abc123')
    end

    it "raises RequiredSwitchMissing when neither form is supplied" do
      expect{build}.to raise_error(RequiredSwitchMissing)
    end

    it "names the hyphenated form in the RequiredSwitchMissing message" do
      expect{build}.to raise_error(RequiredSwitchMissing, /--access-token/)
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
      expect(called).to eq(true)
    end

    it "calls the block when supplied with a long switch" do
      called = false
      build('--action'){called = true}
      expect(called).to eq(true)
    end

    it "doesn't call the block when the switch isn't supplied" do
      called = false
      build{called = true}
      expect(called).to eq(false)
    end

    it "doesn't require an argument" do
      expect{build('-a'){}}.not_to raise_error
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
      expect(argument).to eq('value')
    end

    it "passes the argument to the block when supplied with a long switch" do
      argument = nil
      build('--action value'){|o| argument = o}
      expect(argument).to eq('value')
    end

    it "doesn't call the block when the switch isn't supplied" do
      called = false
      build{called = true}
      expect(called).to eq(false)
    end

    it "raises OptionParser::MissingArgument when no argument is supplied" do
      expect{build('-a'){}}.to raise_error(OptionParser::MissingArgument)
    end
  end
end

describe Switches do
  describe "VERSION" do
    it "is a string" do
      expect(Switches::VERSION).to be_a(String)
    end

    it "is three numbers separated by dots" do
      expect(Switches::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
    end

    it "matches the newest entry in the CHANGELOG" do
      changelog = File.read(File.expand_path('../CHANGELOG', __dir__))
      expect(changelog[/^(\d+\.\d+\.\d+):/, 1]).to eq(Switches::VERSION)
    end
  end
end

describe 'switches.rb.gemspec' do
  let(:spec){Gem::Specification.load(File.expand_path('../switches.rb.gemspec', __dir__))}

  it "is a valid specification" do
    expect(spec.validate).to eq(true)
  end

  it "does not pin a date" do
    expect(spec.date).to eq(Gem::Specification.new.date)
  end

  it "takes its version from Switches::VERSION" do
    expect(spec.version.to_s).to eq(Switches::VERSION)
  end

  it "declares ostruct as its only runtime dependency" do
    expect(spec.runtime_dependencies.map(&:name).sort).to eq(%w{ostruct})
  end

  it "declares its development dependencies" do
    expect(spec.development_dependencies.map(&:name).sort).to eq(%w{rake rspec})
  end
end
