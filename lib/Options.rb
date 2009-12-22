# Switches

# 20091220, 21
# 0.9.0

# Description: This provides for a nice wrapper to OptionParser to also act as a store for options provided.  

# Todo:
# 1. Clean up #set.  Done as of 0.4.0.  

# Ideas: 
# 1. Use ! for options with required switches?  Done as of 0.6.0.  (Changed to being for required arguments in 0.9.0 however.)

# Notes: 
# 1. A limitation is the inability to use the switch, "-?", since there is no Ruby method, #?.  
# 2. An additional limitation is that the Options class cannot have option-methods which are the same as any OptionParser methods since these will be forwarded to the OptionParser instance in the Options class.  
# 3. In 0.9.0 I finally had a clear demarcation between switch arguments and switches themselves being mandatory or optional.  This is way more complicated since the adding of numerous methods and instance variables to Switches to accommodate this distiction.  
# 4. Not that happy with apparently using exclaiming methods in the definition block and then stripping the '!' from the method name before being supplied to OpenStruct.  What to do?...  

# Dependencies: 
# 1. Standard Ruby Library

# Changes since: 0.8:
# 1. /Options/Switches/.  
# 2. /RequiredOptionMissing/RequiredSwitchMissing/.  
# 3. /String#boolean_arg?/String#boolean_switch?/.  
# 4. Other references to options changed to switches.  
# 5. + Switches#required/mandatory/necessary.  
# 6. + Swtiches#optional.  
# 7. + Switches#supplied_switches.  
# 8. + Switches#set_unused_switches_to_nil.  
# 9. ~ self-run section to reflect new interface.  

require 'ostruct'
require 'optparse'

class String
  
  def short_arg?
    self =~ /^.$/ || self =~ /^.\?$/ || self =~ /^.\!$/
  end
  
  def long_arg?
    (self =~ /^..+$/ && !short_arg?) || self =~ /^..+\?$/ || self =~ /^..+!$/
  end
  
  def boolean_switch?
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

class RequiredSwitchMissing < RuntimeError; end

class Switches
  
  def initialize
    @settings = OpenStruct.new
    @op = OptionParser.new
    @required_switches = []
    @all_switches = []
    if block_given?
      yield self
      parse!
    end
  end
  
  def set(*attrs, &block)
    @all_switches = @all_switches + attrs.collect{|a| a.to_s.delete('!')}
    @op.on(*on_args(*attrs, &block)) do |o|
      attrs.each do |attr|
        @settings.send(attr.to_s.delete('!') + '=', o)
      end
    end
  end
  alias_method :optional, :set
  
  def required(*attrs, &block)
    @required_switches = @required_switches + attrs.collect{|a| a.to_s.delete('!')}
    set(*attrs, &block)
  end
  alias_method :mandatory, :required
  alias_method :necessary, :required
  
  def parse!
    @op.parse!
    check_required_switches
    set_unused_switches_to_nil
  end
  
  def supplied_switches
    @settings.instance_variable_get(:@table).keys.collect{|s| s.to_s}
  end
  
  private
  
  def method_missing(method_name, *args, &block)
    if (@op.methods - Switches.instance_methods).include?(method_name.to_s)
      @op.send(method_name.to_s, *args, &block)
    else
      @settings.send(method_name.to_s, *args, &block)
    end
  end
  
  def on_args(*attrs, &block)
    on_args = []
    required_argument = true
    boolean_switch = true
    attrs.collect{|e| e.to_s}.each do |attr|
      required_argument = false if !attr.required_arg?
      boolean_switch = false if !attr.boolean_switch?
      on_args << "-#{attr.long_arg? ? '-' : ''}#{attr.to_s.delete('?').delete('!')}"
    end
    if required_argument
      on_args << (on_args.pop + ' REQUIRED_ARGUMENT')
    elsif boolean_switch
      on_args << (on_args.pop)
    else
      on_args << (on_args.pop + ' [OPTIONAL_ARGUMENT]')
    end
    on_args << yield if block
    on_args
  end
  
  def check_required_switches
    @required_switches.each do |required_switch|
      raise(RequiredSwitchMissing, "required switch, #{required_switch}, is missing") unless supplied_switches.include?(required_switch)
    end
  end
  
  def set_unused_switches_to_nil
    (@all_switches - supplied_switches).each{|s| @settings.send(s + '=', nil)}
  end
  
end

if __FILE__ == $0
  require 'pp'
  switches = Switches.new do |s|
    s.banner = 'Here is a banner.'
    s.set(:f, :file, :filename){'Optionally provide the name of a file to be read in.'}
    s.set(:h!, :host!, :hostname!){'The hostname switch is optional, but has a mandatory argument if used.'}
    s.required(:a, :app, :application){'Necessarily provide an application name, but an argument is optional.'}
    s.required(:b!, :bless!, :blessing!){'Blessings are always necessary, although they will always cause an argument!'}
    s.set(:s?, :sec?, :secure?){'Optionally use a secure connection.'}
    s.required(:r?, :req?, :required?){'Required?'}
    s.optional(:d?, :del?, :delete?){'Optionally delete after action?'}
  end
  pp switches.filename
  pp switches.hostname
  pp switches.application
  pp switches.blessing
  pp switches.secure?
  pp switches.required?
  pp switches.delete?
  puts
  puts switches.help
  puts
end
