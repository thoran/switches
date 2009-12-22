# Options

# 20090207
# 0.4.5

# Description: This provides for a nice wrapper to OptionParser to also act as a store for options provided

# Changes since: 0.3: 
# 1. I've removed the switch list from set and changed it to be a list of switches which defines multiple methods, one per switch.  Much nicer!  
# 0/1
# 2. Refactored #on_args, and while it is shorter, I'm doubtful that it is clearer as to what is happening.  I think the longer one may have been clearer?...  
# 1/2
# 3. Removed the OptionParser instance method specific methods on Options with a 'smarter' #method_missing.  I'm not sure that this is wise, since in a way I've lost some control over the interface and polluted the 'namespace' for potential switch names.  I'll reconsider this one...  
# 2/3
# 4. Refactored #on_args a tiny bit.  
# 3/4
# 5. - __FILE__ == $0 stuff.  
# 4/5
# 6. Refactored #on_args some more, and while it is shorter again, I remain doubtful that it is clearer as to what is happening.  I'm still suspicious that the longer one was clearer?...  

# Todo:
# 1. Clean up #set.  Done as of 0.4.0.  

# Ideas: 
# 1. Use ! for options with required arguments?  

# Notes: 
# 1. A limitation is the inability to use the switch, "-?", since there is no Ruby method, #?.  

# Dependencies: 
# 1. Standard Ruby Library
# 2. Array#last

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
