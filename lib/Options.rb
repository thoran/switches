# Options

# 20090205
# 0.2.7

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
    @op.on(*args){|o| @options.send(attr.to_s + '=', o)}
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

if __FILE__ == $0
  require 'pp'
  
  options = Options.new
  options.set(:form_number, '-n', '--form-number', '--form_number <form_number>', 'This will set the number of the form in order of appearance on the page.  Use zero-based indexing.')
  options.set(:form_name, '-f', '--form', '--form-name', '--form_name <form_name>', 'If left empty, the first form on the page will be used.')
  options.parse!
  
  puts options.form_name
  puts options.form_number
end
