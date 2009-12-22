# Switches

# 20091222
# 0.9.4

# Description: Switches provides for a nice wrapper to OptionParser to also act as a store for switches supplied.  

# Todo:
# 1. Clean up #set.  Done as of 0.4.0.  

# Ideas: 
# 1. Use ! for options with required switches?  Done as of 0.6.0.  (Changed to being for required arguments in 0.9.0 however.)
# 2. Do away with optional arguments entirely.  Since when does anyone want to specify a non-boolean switch and then supply no arguments anyway?...  

# Notes: 
# 1. A limitation is the inability to use the switch, "-?", since there is no Ruby method, #?.  
# 2. An additional limitation is that the Options class cannot have option-methods which are the same as any OptionParser methods since these will be forwarded to the OptionParser instance in the Options class.  
# 3. In 0.9.0 I finally had a clear demarcation between switch arguments and switches themselves being mandatory or optional.  This is way more complicated since the adding of numerous methods and instance variables to Switches to accommodate this distiction.  
# 4. Not that happy with apparently using exclaiming methods in the definition block and then stripping the '!' from the method name before being supplied to OpenStruct.  What to do?...  (Moved the '!' to the method(s) on Switches instead as of 0.9.1.)  
# 5. It mostly makes sense that the Switches interface methods now hold the '!', since it is modifying that switch in place with a required argument, rather than relying upon a default or otherwise set value elsewhere and presumably later than when the switch was set.  

# Dependencies: 
# 1. Standard Ruby Library

# Changes since: 0.8:
# (Renamed this project/class from Options to Switches.)
# 1. /Options/Switches/.  
# 2. /RequiredOptionMissing/RequiredSwitchMissing/.  
# 3. /String#boolean_arg?/String#boolean_switch?/.  
# 4. Other references to options changed to switches.  
# 5. + Switches#required/mandatory/necessary.  
# 6. + Swtiches#optional.  
# 7. + Switches#supplied_switches.  
# 8. + Switches#set_unused_switches_to_nil.  
# 9. ~ self-run section to reflect new interface.  
# 0/1 (Removed ! from switch setting methods and moved those to the Switches interface methods.)
# 10. + Switches#do_set.  
# 11. ~ Switches#set.  
# 12. + Switches#set!.  
# 13. + Switches#required!.  
# 14. - String#required_arg?.  
# 15. ~ Switches#on_args + requires_argument.  
# 1/2 (Added casting to nominated Ruby classes.)
# 16. ~ Switches#on_args + options.  
# 17. + Array#extract_options!.  
# 18. + Switches#allowed.  
# 19. + Switches#allowed!.  
# 20. + Swithces#mandatory.  
# 21. + Switches#necessary.  
# 22. ~ Switches#do_set + ...options.  
# 23. ~ Switches#on_args + ...options[:cast].  
# 24. ~ self-run section to do a simple test of casting.  
# 2/3
# 25. /Options.rb/Switches.rb/.  
# 3/4
# 26. + CastingInterfaceMethods#integer(!).  
# 27. + CastingInterfaceMethods#float(!).  
# 28. + CastingInterfaceMethods#array(!).  
# 29. + CastingInterfaceMethods#regex(p)(!).  
# 30. + CastingInterfaceMethods#boolean(!).  
# 31. ~ Switches#initialize + include_casting_interface_methods.  
# 32. /String#short_arg?/String#short_switch/.  
# 33. /String#long_arg?/String#long_switch/.  
# 34. ~ Switches#on_args - boolean_switch.  

require 'ostruct'
require 'optparse'

class String
  
  def short_switch?
    self =~ /^.$/ || self =~ /^.\?$/ || self =~ /^.\!$/
  end
  
  def long_switch?
    (self =~ /^..+$/ && !short_switch?) || self =~ /^..+\?$/ || self =~ /^..+!$/
  end
  
  def boolean_switch?
    self =~ /\?$/
  end
  
end

class Array
  
  def extract_options!
    last.is_a?(::Hash) ? pop : {}
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

module CastingInterfaceMethods
  
  # It doesn't make sense to cast a non-compulsory switch argument, but this is only so as to avoid errors if that behaviour is desired.  
  def integer(*attrs, &block)
    attrs << {:cast => Integer}
    set(*attrs, &block)
  end
  
  def integer!(*attrs, &block)
    attrs << {:cast => Integer}
    set!(*attrs, &block)
  end
  
  def float(*attrs, &block)
    attrs << {:cast => Float}
    set(*attrs, &block)
  end
  
  def float!(*attrs, &block)
    attrs << {:cast => Float}
    set!(*attrs, &block)
  end
  
  def array(*attrs, &block)
    attrs << {:cast => Array}
    set(*attrs, &block)
  end
  
  def array!(*attrs, &block)
    attrs << {:cast => Array}
    set!(*attrs, &block)
  end
  
  def regexp(*attrs, &block)
    attrs << {:cast => Regexp}
    set(*attrs, &block)
  end
  alias_method :regex, :regexp
  
  def regexp!(*attrs, &block)
    attrs << {:cast => Regexp}
    set!(*attrs, &block)
  end
  alias_method :regex!, :regexp!
  
  def boolean(*attrs, &block)
    attrs.collect!{|a| a.to_s =~ /\?$/ ? a : (a.to_s + '?').to_sym}
    set(*attrs, &block)
  end
  
end

class RequiredSwitchMissing < RuntimeError; end

class Switches
  
  def initialize(include_casting_interface_methods = true)
    self.class.send(:include, CastingInterfaceMethods) if include_casting_interface_methods
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
    do_set(false, *attrs, &block)
  end
  alias_method :optional, :set
  alias_method :allowed, :set
  
  def set!(*attrs, &block)
    do_set(true, *attrs, &block)
  end
  alias_method :optional!, :set!
  alias_method :allowed!, :set!
  
  def required(*attrs, &block)
    @required_switches = @required_switches + attrs.collect{|a| a.to_s}
    set(*attrs, &block)
  end
  alias_method :mandatory, :required
  alias_method :necessary, :required
  alias_method :compulsory, :required
  
  def required!(*attrs, &block)
    @required_switches = @required_switches + attrs.collect{|a| a.to_s}
    set!(*attrs, &block)
  end
  alias_method :mandatory!, :required!
  alias_method :necessary!, :required!
  alias_method :compulsory!, :required!
  
  def parse!
    @op.parse!
    check_required_switches
    set_unused_switches_to_nil
  end
  
  def supplied_switches
    @settings.instance_variable_get(:@table).keys.collect{|s| s.to_s}
  end
  
  private
  
  def do_set(requires_argument, *attrs, &block)
    options = attrs.extract_options!
    @all_switches = @all_switches + attrs.collect{|a| a.to_s}
    @op.on(*on_args(requires_argument, options, *attrs, &block)) do |o|
      attrs.each do |attr|
        @settings.send(attr.to_s + '=', o)
      end
    end
  end
  
  def method_missing(method_name, *args, &block)
    if (@op.methods - Switches.instance_methods).include?(method_name.to_s)
      @op.send(method_name.to_s, *args, &block)
    else
      @settings.send(method_name.to_s, *args, &block)
    end
  end
  
  def on_args(requires_argument, options, *attrs, &block)
    on_args = []
    attrs.collect{|e| e.to_s}.each do |attr|
      on_args << "-#{attr.long_switch? ? '-' : ''}#{attr.to_s.delete('?')}"
    end
    if requires_argument
      on_args << (on_args.pop + ' REQUIRED_ARGUMENT')
    elsif !!attrs.last.to_s.boolean_switch?
      on_args << (on_args.pop)
    else
      on_args << (on_args.pop + ' [OPTIONAL_ARGUMENT]')
    end
    on_args << options[:cast] if options[:cast]
    on_args << yield if block
    on_args
  end
  
  def check_required_switches
    @required_switches.each do |required_switch|
      message = "required switch, -#{required_switch.long_switch? ? '-' : ''}#{required_switch.to_s.delete('?')}, is missing"
      raise(RequiredSwitchMissing, message) unless supplied_switches.include?(required_switch)
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
    s.set!(:h, :host, :hostname){'The hostname switch is optional, but has a mandatory argument if used.'}
    s.required(:a, :app, :application){'Necessarily provide an application name, but an argument is optional.'}
    s.required!(:bless, :blessing){'Blessings are always necessary, yet they will always cause an argument!'}
    s.set(:s?, :sec?, :secure?){'Optionally use a secure connection.'}
    s.required(:r?, :req?, :required?){'Required?'}
    s.optional(:d?, :del?, :delete?){'Optionally delete after action?'}
    s.optional!(:p, :port, :port_number, :cast => Integer){'Otherwise use the default port and cast ye spell and turn it into an integer.'}
    s.optional!(:t, :temp, :temperature, :cast => Float){'Temperature will be cast as a float.'}
    s.integer(:i, :int){'Cast me as an int.'}
    s.boolean(:yes_or_no){'This seems like a step backwards by comparison with ?-methods...'}
  end
  pp switches.filename
  pp switches.hostname
  pp switches.application
  pp switches.blessing
  pp switches.secure?
  pp switches.required?
  pp switches.delete?
  pp switches.port
  pp switches.degrees
  pp switches.temperature
  pp switches.int
  pp switches.yes_or_no?
  puts
  puts switches.help
  puts
end
