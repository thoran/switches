# test/Switches/VERSION_test.rb

require 'minitest/autorun'

require_relative '../../lib/switches'

describe Switches do
  describe "VERSION" do
    it "is a string" do
      _(Switches::VERSION).must_be_kind_of String
    end

    it "is three numbers separated by dots" do
      _(Switches::VERSION).must_match(/\A\d+\.\d+\.\d+\z/)
    end

    it "matches the newest entry in the CHANGELOG" do
      changelog = File.read(File.expand_path('../../CHANGELOG', __dir__))
      _(changelog[/^(\d+\.\d+\.\d+):/, 1]).must_equal Switches::VERSION
    end
  end
end
