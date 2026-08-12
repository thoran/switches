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

  it "declares no runtime dependencies" do
    expect(spec.runtime_dependencies.map(&:name).sort).to eq([])
  end

  it "declares its development dependencies" do
    expect(spec.development_dependencies.map(&:name).sort).to eq(%w{rake rspec})
  end
end
