# Switches.rb
# Switches

# Description: Switches provides for a nice wrapper to OptionParser to also act as a store for switches supplied.  

# Dependencies:
# 1. Standard Ruby Library.
# 2. ostruct, which ceased to be a default gem as of Ruby 4.0 and so is declared in the gemspec.

require 'optparse'
require 'ostruct'

require_relative './Switches/VERSION'

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
class SwitchNameCollision < ArgumentError; end

class Switches
  
  # Names Ruby may call implicitly, and which must reach the settings rather than OptionParser.  #to_a would otherwise answer Array() and the splat with the parser's help.
  NEVER_FORWARDED = [:to_a, :to_ary, :to_h, :to_hash, :to_s, :to_str, :pretty_print]
  
  class << self
    
    def as_h(*args)
      switches = new(*args)
      switches.to_h
    end
    alias_methods :to_h, :as_hash, :as_a_hash, :as_h
    
  end

  attr_accessor :settings

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
    @settings.to_h.keys.collect{|s| s.to_s}
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
    check_switch_names(*attrs)
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
    check_switch_names(*attrs)
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
    if option_parser_method?(method_name) && !declared_switch?(method_name)
      @op.send(method_name, *args, &block)
    else
      @settings.send(method_name, *args, &block)
    end
  end
  
  def option_parser_methods
    @option_parser_methods ||= @op.methods - Switches.instance_methods - NEVER_FORWARDED
  end
  
  def option_parser_method?(method_name)
    option_parser_methods.include?(method_name.to_sym)
  end
  
  def declared_switch?(method_name)
    @all_switches.include?(method_name.to_s.delete_suffix('='))
  end
  
  def check_switch_names(*attrs)
    attrs.each do |attr|
      next unless attr.is_a?(Symbol) || attr.is_a?(String)
      next unless respond_to?(attr.to_s)
      raise SwitchNameCollision, "switch, #{switch_string(attr)}, is already #{method(attr.to_s).owner}##{attr}, so it would never reach the settings"
    end
  end

  def switch_string(attr)
    attr = attr.to_s
    "-#{attr.long_switch? ? '-' : ''}#{attr.delete('?')}"
  end
  
  def on_args(requires_argument, options, *attrs, &block)
    on_args = []
    attrs.collect{|e| e.to_s}.each do |attr|
      @defaults[attr] = options[:default] if options[:default]
      @castings[attr] = (options[:cast] || options[:type] || options[:class]) if (options[:cast] || options[:type] || options[:class])
      on_args << switch_string(attr)
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
        messages << "required switch, #{switch_string(required_switch).tr('_', '-')}, is missing"
      end
    end
    unless messages.empty?
      raise RequiredSwitchMissing, messages.join("\n")
    end
  end
  
  def set_switches_with_defaults
    switches_with_defaults.each do |switch|
      if @settings.to_h[switch.to_sym].nil?
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
