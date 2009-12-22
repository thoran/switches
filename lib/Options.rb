# Options

# 20090927
# 0.6.0

# Description: This provides for a nice wrapper to OptionParser to also act as a store for options provided

# Todo:
# 1. Clean up #set.  Done as of 0.4.0.  

# Ideas: 
# 1. Use ! for options with required arguments?  

# Notes: 
# 1. A limitation is the inability to use the switch, "-?", since there is no Ruby method, #?.  
# 2. An additional limitation is that the Options class cannot have option-methods which are the same as any OptionParser methods since these will be forwarded to the OptionParser instance in the Options class.  

# Dependencies: 
# 1. Standard Ruby Library

# Changes since: 0.5: 
# 1. - require 'Array/lastX' (Using Array#pop instead.)
# 2. Handles 'required' options by use of 'exclamation methods', even though OptionParser doesn't really do anything with that information.  Should throw an error IMO.  
#   a. + String#required_arg?
#   b. ~ String#short_arg?
#   c. ~ String#long_arg?
#   d. ~ Options#on_args
# 3. ~ Options#method_missing (Fixes a minor error with which methods to 'subtract'.)

require 'ostruct'
require 'optparse'

class String
  
  def short_arg?
    self =~ /^.$/ || self =~ /^.\?$/ || self =~ /^.\!$/
  end
  
  def long_arg?
    (self =~ /^..+$/ && !short_arg?) || self =~ /^..+\?$/ || self =~ /^..+!$/
  end
  
  def boolean_arg?
    self =~ /\?$/
  end
  
  def required_arg?
    self =~ /!$/
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
    if (@op.methods - Options.instance_methods).include?(method_name.to_s)
      @op.send(method_name.to_s, *args, &block)
    else
      @options.send(method_name.to_s, *args, &block)
    end
  end
  
  def on_args(*attrs)
    on_args = []
    boolean = true
    required = true
    attrs.collect{|e| e.to_s}.each do |attr|
      boolean = false if !attr.boolean_arg?
      required = false if !attr.required_arg?
      on_args << "-#{attr.long_arg? ? '-' : ''}#{attr.to_s.gsub('?','').gsub('!','')}"
    end
    if required
      on_args << (on_args.pop + ' REQUIRED')
    elsif boolean
      on_args << (on_args.pop)
    else
      on_args << (on_args.pop + ' [OPTIONAL]')
    end
  end
  
end

if __FILE__ == $0
  require 'pp'
  
  options = Options.new
  
  pp options.application
  pp options.hostname!
  pp options.secure?
  
  options.set(:h!, :host!, :hostname!)
  options.soft_parse
  pp options.application
  pp options.hostname!
  pp options.secure?
  
  options.set(:a, :app, :application)
  options.soft_parse
  pp options.application
  pp options.hostname!
  pp options.secure?
  
  options.set(:s?, :sec?, :secure?)
  options.soft_parse
  pp options.application
  pp options.hostname!
  pp options.secure?
  
end
