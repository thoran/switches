# Switches.rb
# Switches

# 20130125, 0513
# 0.9.12

# Description: Switches provides for a nice wrapper to OptionParser to also act as a store for switches supplied.  

# Todo:
# 1. Clean up #set.  Done as of 0.4.0.  
# 2. Reinstitute some specs.  Done as of 0.9.8.  

# Ideas: 
# 1. Use ! for options with required switches?  Done as of 0.6.0.  (Changed to being for required arguments in 0.9.0 however.)
# 2. Do away with optional arguments entirely.  Since when does anyone want to specify a non-boolean switch and then supply no arguments anyway?...  OK, maybe sometimes, but this is pretty obscure IMO.  OK, bad idea.  These can be used as action oriented sub-commands.  
# 3. Allow for any one of the switches OpenStruct methods to assign values for any of the other associated methods, so as it is more than a read once switch and can be used for storage through out the application; although this might be stepping on Attributes.rb's toes?...  

# Notes: 
# 1. A limitation is the inability to use the switch, "-?", since there is no Ruby method, #?.  
# 2. An additional limitation is that the Switches class cannot have methods which are the same as any OptionParser methods since these will be forwarded to the OptionParser instance, @op.  
# 3. In 0.9.0 there is finally now a clear demarcation between switch arguments and switches themselves being mandatory or optional.  
# 4. It mostly makes sense that the Switches interface methods are bang methods, since it is modifying that switch in place with a required argument, rather than relying upon a default or otherwise set value elsewhere and presumably later than when the switch was set.  

# Dependencies: 
# 1. Standard Ruby Library.  

# Changes since 0.8:
# (Renamed this project/class from Options to Switches since there are required switches now and required options don't make sense.)
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
# 2/3 (Renaming the library file.)
# 25. /Options.rb/Switches.rb/.  
# 3/4 (+ casting interface methods)
# 26. + CastingInterfaceMethods#integer(!).  
# 27. + CastingInterfaceMethods#float(!).  
# 28. + CastingInterfaceMethods#array(!).  
# 29. + CastingInterfaceMethods#regex(p)(!).  
# 30. + CastingInterfaceMethods#boolean(!).  
# 31. ~ Switches#initialize + include_casting_interface_methods.  
# 32. /String#short_arg?/String#short_switch?/.  
# 33. /String#long_arg?/String#long_switch?/.  
# 34. ~ Switches#on_args - boolean_switch.  
# 4/5 (Added default values for switches.)
# 35. ~ CastingInterfaceMethods to extract any options before pushing a cast option, since it was overwriting for those casting interface methods.  
# 36. ~ Switches#initialize, + @defaults.  
# 37. /Switches#set_unused_switches_to_nil/Switches#set_unused_switches/.  
# 38. ~ Switches#set_unused_switches, so as it handles setting unused switches with a default.  
# 5/6 (Setting of defaults was overriding supplied switch values.)
# 39. ~ Switches#set_unused_switches, to make use of #switch_defaults and #unused_switches.  
# 40. + Switches#switch_defaults, as an interface method since it might be useful for querying at some point?  
# 41. + Switches#unused_switches, also as an interface method since it might also be useful for querying at some point?  
# 42. ~ Switches#on_args, so as to enable alternate hash keys (:type and :class) for type casting.  
# 43. ~ self-run section to reflect the optionalness/optionality(?) of summaries.  
# 6/7 (Some small tidyups and removal of self-run section.)
# 44. ~ Switches#on_args, shorter when handling casting arguments.  
# 45. /unused_switches/unset_switches/.  
# 46. ~ Switches#check_required_switches, so that the message is not being assigned until a switch is missing.  
# 47. Removed the self-run section and moved it to ./test/run.rb.  
# 7/8 (Addition of #perform and #perform! methods, as well the #do_action method and changes to #on_args to facilitate #perform* methods.)
# 48. ~ Switches#on_args, so as if a block is supplied which is not returning a String, then it will not be placed into the on_args argument list.  
# 49. + Switches#perform, interface for actions which don't require an argument.  
# 50. + Switches#perform!, interface for actions which do require an argument.  
# 51. + Switches#do_action, executes a block when called by either of #perform or #perform!.  
# 8/9
# 52. ~ Switches#check_required_switches, so as it now assembles the complete list of missing switches rather than failing on and reporting only the first.  
# 53. + Switches#required_perform
# 54. + Switches#required_perform!
# 55. - OptionParse#soft_parse, since this was never used here, but only in Attributes.  
# 56. + Object#default_is(et.al.)
# 57. + NilClass#default_is(et.al.) overrides Object#default_is for the specific case of nil.  
# 58. /switches_defaults/switches_with_defaults/.  
# 59. + Array#peek_options.  
# 60. + Array#poke_options!.  
# 61. + Array#all_but_last.  
# 62. + Array#last!.  
# 63. + Module#alias_methods.  
# 64. ~ CastingInterfaceMethods, to make use of Array#poke_options.  
# 65. + CastingInterfaceMethods#flag.  
# 66. + Switches.as_h (and associated aliased interfaces).  
# 67. ~ Switches#initialize, arguments are now a splat with the intention of allowing both casting_interface_methods and as_h being specified as a hash supplied to the initialiser.  
# 68. ~ Switches, to make use of Module#alias_methods.  
# 69. ~ Switches, to make use of Array#peek_options and Array#poke_options!.  
# 70. + Switches#required_perform.  
# 71. + Switches#required_perform!.  
# 72. + Switches#switches_with_defaults.  
# 73. + Switches#switches_with_castings.  
# 74. + Swtiches#to_h.  
# 75. + Switches#set_if_required_switch.  
# 76. + Switches#set_switches_with_defaults.  
# 77. ~ Switches#parse!, + set_switches_with_defaults() and + to_h().  
# 78. ~ Switches#do_set, + set_if_required_switch().  
# 79. ~ Switches#do_action, + set_if_required_switch().  
# 80. ~ Switches#on_args, so as it can handle castings.  
# 9/10
# 81. + OpenStruct#to_h.  
# 82. ~ Switches#to_h.  
# 10/11 (Whoops!  The defaults were overwriting the supplied settings.)
# 83. ~ Switches#set_switches_with_defaults to check if a setting had been set before applying a default value.   
# 11/12 (Removed default aliases for default_to, since it clashes with the mail gem's Mail::Message#default method.)
# 84. - Object#default.  
# 85. - NilClass#default.  

require 'optparse'
require 'ostruct'

class OpenStruct
  
  def to_h
    @table
  end
  
end

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
  
  def peek_options
    last.is_a?(::Hash) ? last : {}
  end
  
  def poke_options!(h)
    self << self.extract_options!.merge(h)
  end
  
  alias_method :last!, :pop
  
  def all_but_last
    d = self.dup
    d.last!
    d
  end
  
end

class Object
  
  def default_is(o)
    self
  end
  alias_method :defaults_to, :default_is
  alias_method :default_to, :default_is
  
end

class NilClass
  
  def default_is(o)
    o
  end
  alias_method :defaults_to, :default_is
  alias_method :default_to, :default_is
  
end

class Module
  
  def alias_methods(*args)
    args.all_but_last.each{|e| alias_method e.to_sym, args.last.to_sym}
  end
  
end

module CastingInterfaceMethods
  
  def integer(*attrs, &block)
    attrs.poke_options!({:cast => Integer})
    set(*attrs, &block)
  end
  
  def integer!(*attrs, &block)
    attrs.poke_options!({:cast => Integer})
    set!(*attrs, &block)
  end
  
  def float(*attrs, &block)
    attrs.poke_options!({:cast => Float})
    set(*attrs, &block)
  end
  
  def float!(*attrs, &block)
    attrs.poke_options!({:cast => Float})
    set!(*attrs, &block)
  end
  
  def array(*attrs, &block)
    attrs.poke_options!({:cast => Array})
    set(*attrs, &block)
  end
  
  def array!(*attrs, &block)
    attrs.poke_options!({:cast => Array})
    set!(*attrs, &block)
  end
  
  def regexp(*attrs, &block)
    attrs.poke_options!({:cast => Regexp})
    set(*attrs, &block)
  end
  alias_method :regex, :regexp
  
  def regexp!(*attrs, &block)
    attrs.poke_options!({:cast => Regexp})
    set!(*attrs, &block)
  end
  alias_method :regex!, :regexp!
  
  def boolean(*attrs, &block)
    attrs.collect!{|a| a.to_s =~ /\?$/ ? a : (a.to_s + '?').to_sym}
    set(*attrs, &block)
  end
  alias_method :flag, :boolean
  
end

class RequiredSwitchMissing < RuntimeError; end

class Switches
  
  class << self
    
    def as_h(*args)
      switches = new(*args)
      switches.to_h
    end
    alias_methods :to_h, :as_hash, :as_a_hash, :as_h
    
  end
  
  def initialize(*args)
    options = args.extract_options!
    self.class.send(:include, CastingInterfaceMethods) if options[:include_casting_interface_methods].default_is(true)
    @as_h = (options[:as_h] || options[:to_h] || options[:as_hash] || options[:as_a_hash]).default_is(false)
    @settings = OpenStruct.new
    @op = OptionParser.new
    @required_switches = []
    @all_switches = []
    @defaults = {}
    @castings = {}
    if block_given?
      yield self
      parse!
    end
  end
  
  def set(*attrs, &block)
    do_set(false, *attrs, &block)
  end
  alias_methods :optional_switch, :optional, :set
  
  def set!(*attrs, &block)
    do_set(true, *attrs, &block)
  end
  alias_methods :optional_switch!, :optional!, :set!
  
  def required(*attrs, &block)
    attrs.poke_options!({:required => true})
    set(*attrs, &block)
  end
  alias_method :required_switch, :required
  
  def required!(*attrs, &block)
    attrs.poke_options!({:required => true})
    set!(*attrs, &block)
  end
  alias_method :required_switch!, :required!
  
  def perform(*attrs, &block)
    do_action(false, *attrs, &block)
  end
  alias_methods :optionally_perform, :optional_perform, :perform
  
  def perform!(*attrs, &block)
    do_action(true, *attrs, &block)
  end
  alias_methods :optionally_perform!, :optional_perform!, :perform!
  
  def required_perform(*attrs, &block)
    attrs.poke_options!({:required => true})
    perform(*attrs, &block)
  end
  
  def required_perform!(*attrs, &block)
    attrs.poke_options!({:required => true})
    perform!(*attrs, &block)
  end
  
  def parse!
    @op.parse!
    check_required_switches
    set_switches_with_defaults
    set_unset_switches
    to_h if @as_h
  end
  
  def supplied_switches
    @settings.instance_variable_get(:@table).keys.collect{|s| s.to_s}
  end
  
  def switches_with_defaults
    @defaults.keys.collect{|default| default.to_s}
  end
  
  def switches_with_castings
    @castings.keys.collect{|default| default.to_s}
  end
  
  def unset_switches
    @all_switches - supplied_switches - switches_with_defaults
  end
  
  def to_h
    @settings.to_h
  end
  
  private
  
  def do_set(requires_argument, *attrs, &block)
    set_if_required_switch(*attrs)
    options = attrs.extract_options!
    @all_switches = @all_switches + attrs.collect{|a| a.to_s}
    @op.on(*on_args(requires_argument, options, *attrs, &block)) do |o|
      attrs.each do |attr|
        @settings.send(attr.to_s + '=', o)
      end
    end
  end
  
  def do_action(requires_argument, *attrs, &block)
    attrs.each do |attr|
      @settings.send(attr.to_s + '=', nil) # Needs to be set prior to checking for required switches, since that check relies upon the key having been set in @settings.  
    end
    set_if_required_switch(*attrs)
    options = attrs.extract_options!
    @all_switches = @all_switches + attrs.collect{|a| a.to_s}
    @op.on(*on_args(requires_argument, options, *attrs)) do |o|
      yield o if block
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
      @defaults[attr] = options[:default] if options[:default]
      @castings[attr] = (options[:cast] || options[:type] || options[:class]) if (options[:cast] || options[:type] || options[:class])
      on_args << "-#{attr.long_switch? ? '-' : ''}#{attr.to_s.delete('?')}"
    end
    if requires_argument
      on_args << (on_args.pop + ' REQUIRED_ARGUMENT')
    elsif !!attrs.last.to_s.boolean_switch?
      on_args << (on_args.pop)
    else
      on_args << (on_args.pop + ' [OPTIONAL_ARGUMENT]')
    end
    on_args << (options[:cast] || options[:type] || options[:class]) if (options[:cast] || options[:type] || options[:class])
    if block
      yield_result = yield
      on_args << yield_result if yield_result.class == String
    end
    on_args
  end
  
  def check_required_switches
    messages = []
    @required_switches.each do |required_switch|
      unless supplied_switches.include?(required_switch)
        messages << "required switch, -#{required_switch.long_switch? ? '-' : ''}#{required_switch.to_s.delete('?')}, is missing"
      end
    end
    unless messages.empty?
      raise RequiredSwitchMissing, messages.join("\n")
    end
  end
  
  def set_switches_with_defaults
    switches_with_defaults.each do |switch|
      if @settings.instance_variable_get(:@table)[switch.to_sym].nil?
        if switches_with_castings.include?(switch)
          cast_value = (
            case @castings[switch]
            when Integer; @defaults[switch].to_i
            when Float; @defaults[switch].to_f
            when Array; @defaults[switch].to_a
            when Regexp; Regexp.new(@defaults[switch])
            end
          )
          @settings.send(switch + '=', cast_value)
        else
          @settings.send(switch + '=', @defaults[switch])
        end
      end
    end
  end
  
  def set_unset_switches
    unset_switches.each{|switch| @settings.send(switch + '=', nil)}
  end
  
  def set_if_required_switch(*attrs)
    if (attrs.peek_options[:required] || attrs.peek_options[:required_switch])
      attrs.extract_options!
      @required_switches = @required_switches + attrs.collect{|a| a.to_s}
    end
  end
  
end
