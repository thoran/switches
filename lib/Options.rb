# Options

# 20090207
# 0.4.0

# Description: This provides for a nice wrapper to OptionParser to also act as a store for options provided

# Changes since: 0.3: 
# 1. I've removed the switch list from set and changed it to be a list of switches which defines multiple methods, one per switch.  Much nicer!  

# Todo:
# 1. Clean up #set.  

# Ideas: 
# 1. Use ! for options with required arguments?  

# Notes: 
# 1. A limitation is the inability to use the switch, "-?", since there is no Ruby method, #?.  

require 'ostruct'
require 'optparse'
require 'Array/lastX'

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
  
end # class String

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
    @myvalue = nil
    @op.on(*on_args(*attrs)) do |o|
      attrs.each do |attr|
        @options.send(attr.to_s + '=', o)
      end
    end
  end
  
  def on(*args, &block)
    @op.on(*args, &block)
  end
  
  def banner=(s)
    @op.banner = s
  end
  
  def parse!
    @op.parse!
  end
  
  def method_missing(method_name, *args, &block)
    @options.send(method_name.to_s, *args, &block)
  end
  
  private
  
  def on_args(*attrs)
    on_args = []
    boolean = true
    attrs.each do |attr|
      attr = attr.to_s
      if attr.short_arg? && !attr.boolean_arg? # -s arg
        on_args << "-#{attr}"
        boolean = false
      elsif attr.short_arg? && attr.boolean_arg? # -s
        on_args << "-#{attr.to_s.gsub('?','')}"
      elsif attr.long_arg? && !attr.boolean_arg? # --switch arg
        on_args << "--#{attr}"
        boolean = false
      elsif attr.long_arg? && attr.boolean_arg? # --switch
        on_args << "--#{attr.to_s.gsub('?','')}"
      end # if
    end # attrs.each...
    if !boolean
      on_args << (on_args.last! + ' <>')
    end
    on_args
  end
  
end

if __FILE__ == $0
  options = Options.new do |opts|
    opts.set(:r?, :form_required?, :required?)
    opts.set(:f, :form)
  end
  
  puts options.r?
  puts options.form_required?
  puts options.required?
  
  puts options.f
  puts options.form
end
