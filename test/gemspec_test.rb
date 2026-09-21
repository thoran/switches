# test/gemspec_test.rb

require 'minitest/autorun'

require_relative '../lib/switches'

describe 'switches.rb.gemspec' do
  let(:spec){Gem::Specification.load(File.expand_path('../switches.rb.gemspec', __dir__))}

  it "is a valid specification" do
    _(spec.validate).must_equal true
  end

  it "does not pin a date" do
    _(spec.date).must_equal Gem::Specification.new.date
  end

  it "takes its version from Switches::VERSION" do
    _(spec.version.to_s).must_equal Switches::VERSION
  end

  it "declares ostruct as its only runtime dependency" do
    _(spec.runtime_dependencies.map(&:name).sort).must_equal %w{ostruct}
  end

  it "declares its development dependencies" do
    _(spec.development_dependencies.map(&:name).sort).must_equal %w{minitest rake}
  end
end
