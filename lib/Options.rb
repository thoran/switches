# Options

# 20091203
# 0.7.0

# Description: This provides for a nice wrapper to OptionParser to also act as a store for options provided

# Todo:
# 1. Clean up #set.  Done as of 0.4.0.  

# Ideas: 
# 1. Use ! for options with required arguments?  Done as of 0.6.0.  

# Notes: 
# 1. A limitation is the inability to use the switch, "-?", since there is no Ruby method, #?.  
# 2. An additional limitation is that the Options class cannot have option-methods which are the same as any OptionParser methods since these will be forwarded to the OptionParser instance in the Options class.  

# Dependencies: 
# 1. Standard Ruby Library

# Changes since: 0.6: 
# 1. Option summaries can now be included by passing a block to Options#set.  
# 2. Discovered(?!) that OptionParser#banner= and OptionParser#help make use of Options#method_missing routing to direct calls to the appropriate place to enable usage output.  

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
  
  def set(*attrs, &block)
    attrs.each do |attr|
      @options.send(attr.to_s + '=', nil)
    end
    @op.on(*on_args(*attrs, &block)) do |o|
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
  
  def on_args(*attrs, &block)
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
    on_args << yield if block
    on_args
  end
  
end

if __FILE__ == $0
  require 'pp'
  
  options = Options.new
  
  pp options.application
  pp options.hostname!
  pp options.secure?
  pp options.filename
  puts
  options.set(:a, :app, :application)
  options.soft_parse
  pp options.application
  pp options.hostname!
  pp options.secure?
  pp options.filename
  puts
  options.set(:h!, :host!, :hostname!)
  options.soft_parse
  pp options.application
  pp options.hostname!
  pp options.secure?
  pp options.filename
  puts
  options.set(:s?, :sec?, :secure?)
  options.soft_parse
  pp options.application
  pp options.hostname!
  pp options.secure?
  pp options.filename
  puts
  options.set(:f, :file, :filename){'The name of a file to be read in.'}
  options.soft_parse
  pp options.application
  pp options.hostname!
  pp options.secure?
  pp options.filename
  puts
  options = Options.new do |opts|
    opts.banner = 'Here is a banner.'
    opts.set(:h!, :host!, :hostname!){'The hostname is required.'}
    opts.set(:a, :app, :application){'Optionally provide an application name.'}
    opts.set(:s?, :sec?, :secure?){'Use a secure connection?'}
    opts.set(:f, :file, :filename){'Optionally provide the name of a file to be read in.'}
  end
  pp options.application
  pp options.hostname!
  pp options.secure?
  pp options.filename
  puts
  puts options.help
  
end
