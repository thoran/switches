# Options

# 20090321, 22
# 0.5.0

# Description: This provides for a nice wrapper to OptionParser to also act as a store for options provided

# Changes since: 0.4: 
# 1. + OptionParser#soft_parse.  This was needed for #attribute in Attributes to work correctly.  Perhaps it doesn't need to strictly be a part of Options, but it'll do in here for now.  

# Todo:
# 1. Clean up #set.  Done as of 0.4.0.  

# Ideas: 
# 1. Use ! for options with required arguments?  

# Notes: 
# 1. A limitation is the inability to use the switch, "-?", since there is no Ruby method, #?.  
# 2. An additional limitation is that the Options class cannot have option-methods which are the same as any OptionParser methods since these will be forwarded to the OptionParser instance in the Options class.  

# Dependencies: 
# 1. Standard Ruby Library
# 2. Array#last!

require 'ostruct'
require 'optparse'
require 'Array/lastX'
require 'pp'

class String
  
  def short_arg?
    self =~ /^.$/ || self =~ /^.\?$/
  end
  
  def long_arg?
    self =~ /^..+$/ || self =~ /^..+\?$/
  end
  
  def boolean_arg?
    self =~ /\?$/
  end
  
end

class OptionParser
  
  def soft_parse
    argv = default_argv.dup
    loop do
      begin
        parse(argv)
        return
      rescue OptionParser::InvalidOption
        argv.shift
      end
    end
  end
  
end

class Options
  
  def initialize
    @options = OpenStruct.new
    @op = OptionParser.new
    if block_given?
      yield self
      parse!
    end
  end
  
  def set(*attrs)
    @op.on(*on_args(*attrs)) do |o|
      attrs.each do |attr|
        @options.send(attr.to_s + '=', o)
      end
    end
  end
  
  private
  
  def method_missing(method_name, *args, &block)
    if (@op.methods - Object.instance_methods).include?(method_name.to_s)
      @op.send(method_name.to_s, *args, &block)
    else
      @options.send(method_name.to_s, *args, &block)
    end
  end
  
  def on_args(*attrs)
    on_args = []
    boolean = true
    attrs.collect{|e| e.to_s}.each do |attr|
      boolean = false if !attr.boolean_arg?
      on_args << "-#{attr.long_arg? ? '-' : ''}#{attr.to_s.gsub('?','')}"
    end
    on_args << (on_args.last! + ' <>') if !boolean
    on_args
  end
  
end

if __FILE__ == $0
  
  options = Options.new
  
  pp options.application
  pp options.hostname
  
  options.set(:h, :host, :hostname)
  options.soft_parse
  pp options.application
  pp options.hostname
  
  options.set(:a, :app, :application)
  options.soft_parse
  pp options.application
  pp options.hostname
  
end
