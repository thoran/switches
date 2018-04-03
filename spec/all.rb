require "#{File.dirname(__FILE__)}/../lib/Switches"

class Array
  
  alias_method :empty!, :clear
  
end

describe Switches do
  
  describe ".new" do
    
    it "should return an object of class Switches" do
      Switches.new.class.should == Switches
    end
    
  end
  
  describe "#set" do
    
    def setup(switches_string = '')
      ARGV.empty!
      switches_string.split.each{|a| ARGV << a}
      Switches.new do |s|
        s.set :v?, :verbose?
        s.set :p, :port
        s.set :host, :h
      end
    end
    
    it "should set a short boolean switch or flag to true when supplied with a short switch" do
      setup('-v').v?.should == true
    end
    
    it "should set a long boolean switch value to true when supplied with a short switch" do
      setup('-v').verbose?.should == true
    end
    
    it "should set a short boolean switch or flag to true when supplied with a long switch" do
      setup('--verbose').v?.should == true
    end
    
    it "should set a long boolean switch or flag to true when supplied with a long switch" do
      setup('--verbose').verbose?.should == true
    end
    
    it "should set a short switch value to the value supplied when supplied with a short switch" do
      setup('-p 22').p.should == '22'
    end
    
    it "should set a long switch value to the value supplied when supplied with a short switch" do
      setup('-p 22').port.should == '22'
    end
    
    it "should set a short switch value to the value supplied when supplied with a long switch" do
      setup('--port 22').p.should == '22'
    end
    
    it "should set a long switch value to the value supplied when supplied with a long switch" do
      setup('--port 22').port.should == '22'
    end
    
    it "shouldn't matter in which order the short and long switches are given" do
      setup('-h example.com').h.should == 'example.com'
      setup('--host example.com').h.should == 'example.com'
    end
    
  end # describe "#set"
  
  describe "#set!" do
    
    def setup(switches_string = '')
      ARGV.empty!
      switches_string.split.each{|a| ARGV << a}
      Switches.new do |s|
        s.set! :p, :port
      end
    end
    
    it "should set a short switch value to the argument supplied with a short switch" do
      setup('-p 22').p.should == '22'
    end
    
    it "should set a long switch value to the argument supplied with a short switch" do
      setup('-p 22').port.should == '22'
    end
    
    it "should set a short switch value to the argument supplied with a long switch" do
      setup('--port 22').p.should == '22'
    end
    
    it "should set a long switch value to the argument supplied with a long switch" do
      setup('--port 22').port.should == '22'
    end
    
    it "should raise a MissingArgument error when no argument is supplied to a short switch" do
      switches = lambda{setup('-p')}
      switches.should{raise MissingArgument}
    end
    
    it "should raise a MissingArgument error when no argument is supplied to a long switch" do
      switches = lambda{setup('--port')}
      switches.should{raise MissingArgument}
    end
    
  end # describe "#set!"
  
  describe "#required" do
    
    def setup(switches_string = '')
      ARGV.empty!
      switches_string.split.each{|a| ARGV << a}
      Switches.new do |s|
        s.required :p, :port
      end
    end
    
    it "should set a short switch value to the argument supplied with a short switch" do
      setup('-p 22').p.should == '22'
    end
    
    it "should set a long switch value to the argument supplied with a short switch" do
      setup('-p 22').port.should == '22'
    end
    
    it "should set a short switch value to the argument supplied with a long switch" do
      setup('--port 22').p.should == '22'
    end
    
    it "should set a long switch value to the argument supplied with a long switch" do
      setup('--port 22').port.should == '22'
    end
    
    it "should raise a RequiredSwitchMissing error no switch is supplied" do
      switches = lambda{setup}
      switches.should{raise RequiredSwitchMissing}
    end
    
  end # describe "#required"
  
  describe "#required!" do
    
    def setup(switches_string = '')
      ARGV.empty!
      switches_string.split.each{|a| ARGV << a}
      Switches.new do |s|
        s.required! :p, :port
      end
    end
    
    it "should set a short switch value to the argument supplied with a short switch" do
      setup('-p 22').p.should == '22'
    end
    
    it "should set a long switch value to the argument supplied with a short switch" do
      setup('-p 22').port.should == '22'
    end
    
    it "should set a short switch value to the argument supplied with a long switch" do
      setup('--port 22').p.should == '22'
    end
    
    it "should set a long switch value to the argument supplied with a long switch" do
      setup('--port 22').port.should == '22'
    end
    
    it "should raise a MissingArgument error when no argument is supplied to a short switch" do
      switches = lambda{setup('-p')}
      switches.should{raise MissingArgument}
    end
    
    it "should raise a MissingArgument error when no argument is supplied to a long switch" do
      switches = lambda{setup('-p')}
      switches.should{raise MissingArgument}
    end
    
    it "should raise a RequiredSwitchMissing error no switch is supplied" do
      switches = lambda{setup}
      switches.should{raise RequiredSwitchMissing}
    end
    
  end # describe "#required!"
  
  describe "#perform" do
    
    def setup(switches_string = '')
      ARGV.empty!
      switches_string.split.each{|a| ARGV << a}
      Switches.new do |s|
        s.perform(:action){an_action}
      end
    end
    
    def an_action
      'value'
    end
    
    it "should send(:an_action)"
    
  end # describe "#perform"
  
  describe "#perform!" do
    
    def setup(switches_string = '')
      ARGV.empty!
      switches_string.split.each{|a| ARGV << a}
      Switches.new do |s|
        s.perform(:action){an_action}
      end
    end
    
    def an_action
      'value'
    end
    
    it "should send(:an_action)"
    
    it "should require a block parameter"
    
  end # describe "#perform!"
  
end # describe Switches
