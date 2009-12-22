# Options

# 20090206
# 0.3.1

# Description: This provides for a nice wrapper to OptionParser to also act as a store for options provided

# Changes: 
# 1. It is now possible to just use the method name.  
# 0/1
# 2. It is now possible to use short args.  
# 3. It is now possible to have boolean switches.  

require 'ostruct'
require 'optparse'

class Options
  
  def initialize
    @options = OpenStruct.new
    @op = OptionParser.new
    if block_given?
      yield self
      parse!
    end
  end
  
  def set(attr, *args)
    if args.empty?
      if attr.is_a?(Hash)
        case attr.key.to_sym
        when :boolean, :noarg, :no_arg
          @op.on("-#{attr}"){|o| @options.send(attr.to_s + '=', o)}
        when :arg
          @op.on("--#{attr}"){|o| @options.send(attr.to_s + '=', o)}
        else
          @op.on("-#{attr}"){|o| @options.send(attr.to_s + '=', o)}
        end
      else
        case attr
        when /^.$/
          @op.on("-#{attr} <>"){|o| @options.send(attr.to_s + '=', o)}
        else
          @op.on("--#{attr} <>"){|o| @options.send(attr.to_s + '=', o)}
        end
      end
    else
      @op.on(*args){|o| @options.send(attr.to_s + '=', o)}
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
  
  
end

if __FILE__ == $0
  require 'pp'
  
  options = Options.new do |opts|
    opts.set(:form_number)
    opts.set(:form_name)
  end
  
  puts options.form_name
  puts options.form_number
end
