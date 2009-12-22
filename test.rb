require 'pp'
#require 'lib/1'
require 'ostruct'
require 'optparse'
require 'ruby-debug'

class Options < OpenStruct
  
  def initialize
    #@options = OpenStruct.new
    @op = OptionParser.new
    if block_given?
      yield self
      #parse!
    end
  end
  
  def set(attr, *opts)
    option = nil
    @op.on(*opts) do |opt|
      option = opt
    end
    @options.send(attr.to_s + '=', option)
  end
  
  def on(*opts, &block)
    pp 'here'
    @op.on(*opts, &block)
  end
  
  def banner=(s)
    @op.banner = s
  end
  
  def parse!
    @op.parse!
  end
  
  # def method_missing(missing_method, *args, &block)
  #   @options.send(missing_method, *args, &block)
  # end
  
end # class Options

# options = Options.new do |options|
#   pp options.class
#   options.on('-f', '--form', '--form-name', '--form_name <form_name>', 'If left empty, the first form on the page will be used.') do |o|
#     options.form_name = o
#     options.methods.include?('form_name')
#   end
# end

#@options.on('-n', '--form-number', '--form_number <form_number>', 'This will set the number of the form in order of appearance on the page.  Use zero-based indexing.') do |opt|
#  @options.form_number = opt
#end

class Options
  #class << self
    
    def initialize
      @options = OpenStruct.new
      @op = OptionParser.new
    end
    
    def set(attr, *args)
      #options = OpenStruct.new
      #op = OptionParser.new do |opts|
        @op.on(*args){|o| @options.send(attr.to_s + '=', o)}
      #end #.parse!
      @options
    end
    
    def parse!
      @op.parse!
    end
    
    def method_missing(method_name, *args, &block)
      @options.send(method_name.to_s, *args, &block)
    end
  #end
end

options = Options.new
options.set(:form_number, '-n', '--form-number', '--form_number <form_number>', 'This will set the number of the form in order of appearance on the page.  Use zero-based indexing.')
options.set(:form_name, '-f', '--form', '--form-name', '--form_name <form_name>', 'If left empty, the first form on the page will be used.')
options.parse!

#options.methods.include?('form_name')

puts options.form_name
puts options.form_number

#puts @options.form_number
#pp @options.methods.include?('form_name')
#pp @options.methods.include?('form_number')
