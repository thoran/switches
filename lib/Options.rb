# Options

# 20080826
# 0.?.0

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

require 'optparse'
require 'ostruct'

class Options < OpenStruct
  
  def initialize
    @op = OptionParser.new
    yield self if block_given?
    parse if block_given?
    super
  end
  
  def set(attr, *opts, &block)
    @op.on(opts, block) do |opt|
      self.send(attr.to_s + '=', opt)
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
