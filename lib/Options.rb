# Options

# 20090206
# 0.3.4

# Description: This provides for a nice wrapper to OptionParser to also act as a store for options provided

# Changes: 
# 1. It is now possible to just use the method name.  
# 0/1
# 2. It is now possible to use short args.  
# 3. It is now possible to have boolean switches.  
# 1/2
# 4. It is now possible to have boolean switches which are implied, since I've removed the possibility for explicit switches.  
# 2/3
# 5. The begin-rescue stuff didn't work, and I don't care why right now.  So, instead I am using arguments to set which may or may not include a ? as per Ruby.  This works for both long and short switches.  
# 3/4
# 6. Took the diagnosticy stuff out.  

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
      case attr.to_s
      when /^.\?$/ # -s
        @op.on("-#{attr.to_s.gsub('?','')}"){|o| @options.send(attr.to_s + '=', o)}
      when /^.$/ # -s arg
        @op.on("-#{attr} <>"){|o| @options.send(attr.to_s + '=', o)}
      when /^..+\?$/ # --switch
        @op.on("--#{attr.to_s.gsub('?','')}"){|o| @options.send(attr.to_s + '=', o)}
      when /^..+$/ # --switch arg
        @op.on("--#{attr} <>"){|o| @options.send(attr.to_s + '=', o)}
      end # case
    else
      @op.on(*args){|o| @options.send(attr.to_s + '=', o)}
    end # if
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
  
end
