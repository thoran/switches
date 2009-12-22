#20090204, 05

require File.expand_path(File.dirname(__FILE__) + '/../lib/1')

describe Options, "when using no block with the constructor" do
  
  setup do
    @options = Options.new
    @options.set(:form_name, '-f', '--form', '--form-name', '--form_name <form_name>', 'If left empty, the first form on the page will be used.')
    @options.on('-n', '--form-number', '--form_number <form_number>', 'This will set the number of the form in order of appearance on the page.  Use zero-based indexing.') do |opt|
      self.form_number = opt
    end
  end
  
  it "should be able to access the values" do
    @options.form_name.should == 'something'
  end
  
end

describe Options, "when using a block with the constructor" do
  
  setup do
    @options = Options.new do |opts|
      opts.set(:form_name, '-f', '--form', '--form-name', '--form_name <form_name>', 'If left empty, the first form on the page will be used.')
      opts.on('-n', '--form-number', '--form_number <form_number>', 'This will set the number of the form in order of appearance on the page.  Use zero-based indexing.') do |opt|
        self.form_number = opt
      end
    end
  end
  
  it "should be able to access the values" do
    @options.form_name
  end
  
end
