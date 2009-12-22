#20090205

require 'pp'

require File.expand_path(File.dirname(__FILE__) + '/../lib/3')

describe Options, 'when using no block with the constructor' do
  
  describe 'and when using #set' do
    setup do
      @options = Options.new
      @options.set(:form_name, '-f', '--form', '--form-name', '--form_name <form_name>', 'If left empty, the first form on the page will be used.')
    end
    
    it 'should be able to access the value' do
      @options.form_name.should == 'FORM'
    end
  end
  
  describe 'and when using #on' do
    setup do
      @options = Options.new
      @options.on('-n', '--form-number', '--form_number <form_number>', 'This will set the number of the form in order of appearance on the page.  Use zero-based indexing.') do |opt|
        self.form_number = opt
      end
    end
    
    it 'should be able to access the value' do
      @options.form_number
    end
  end
  
end

describe Options, 'when using a block with the constructor' do
  
  describe 'and when using #set' do
    
    setup do
      @options = Options.new do |opts|
        opts.set(:form_name, '-f', '--form', '--form-name', '--form_name <form_name>', 'If left empty, the first form on the page will be used.')
      end
    end
    
    it 'should be able to access the value' do
      @options.form_name
    end
    
  end
  
  describe 'and when using #on' do
  
    setup do
      @options = Options.new do |opts|
        opts.on('-n', '--form-number', '--form_number <form_number>', 'This will set the number of the form in order of appearance on the page.  Use zero-based indexing.') do |opt|
          self.form_number = opt
        end
      end
    end
    
    it 'should be able to access the value' do
      @options.form_number
    end
    
  end
  
end
