# Options

# 20090204, 05
# 0.2.2

# Description: 

# Discussion: 
# 1. Instead of explicitly defining the corresponding OptionParser methods, I could use method_missing and then avoid OpenStruct's desire to create new methods?!?  

# Examples: 
# 1. Using no block with the constructor...
# options = Options.new
# options.set(:form_name, '-f', '--form', '--form-name', '--form_name <form_name>', 'If left empty, the first form on the page will be used.')
# options.on('-n', '--form-number', '--form_number <form_number>', 'This will set the number of the form in order of appearance on the page.  Use zero-based indexing.') do |opt|
#  self.form_number = opt
# end
# 2. Using a block with the constructor...
# options = Options.new do |opts|
#   opts.set(:form_name, '-f', '--form', '--form-name', '--form_name <form_name>', 'If left empty, the first form on the page will be used.')
#   opts.on('-n', '--form-number', '--form_number <form_number>', 'This will set the number of the form in order of appearance on the page.  Use zero-based indexing.') do |opt|
#     self.form_number = opt
#   end
# end
# 3. Accessing the values...
# options.form_name
# options.form_number

# Changes: 
# 1. 

require 'optparse'
require 'ostruct'
require 'pp'

class Options
  
  def initialize
    @op = OptionParser.new
    @options = OpenStruct.new
    if block_given?
      yield self
      parse!
    end
    super
  end
  
  def set(attr, *opts)
    @op.on(*opts) do |opt|
      @options.send(attr.to_s + '=', opt)
    end
  end
  
  def on(*opts, &block)
    @op.on(opts, block)
  end
  
  def banner=(s)
    @op.banner = s
  end
  
  def parse!
    @op.parse!
  end
  
end # class Options
