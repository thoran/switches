# test/loading_test.rb

require 'minitest/autorun'

require_relative '../lib/switches'

# In its own process, since this one has loaded the file directly and so could
# not tell what requiring the gem by its own name would bring.
describe 'loading' do
  def ruby(source)
    lib = File.expand_path('../lib', __dir__)
    IO.popen(['ruby', "-I#{lib}", '-e', source], err: [:child, :out]){|io| io.read}.strip
  end

  # The gem is switches.rb, so require 'switches.rb' reads lib/switches.rb.  A
  # capitalised lib/Switches.rb answers that only on a case-insensitive
  # filesystem, which is to say on the machine it was written on and not on
  # Linux.  Dir.entries reports the name as stored, so this asks exactly what a
  # case-sensitive filesystem would ask.
  it "carries the lowercase file the gem's name asks for" do
    _(Dir.entries(File.expand_path('../lib', __dir__))).must_include 'switches.rb'
  end

  it "defines Switches upon requiring the gem by name" do
    _(ruby('require "switches.rb"; print defined?(Switches)')).must_equal 'constant'
  end

  it "defines the version too" do
    _(ruby('require "switches.rb"; print Switches::VERSION')).must_equal Switches::VERSION
  end

  it "answers to the name without its extension as well" do
    _(ruby('require "switches"; print defined?(Switches)')).must_equal 'constant'
  end
end
