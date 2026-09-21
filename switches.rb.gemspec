# switches.rb.gemspec

require_relative './lib/Switches/VERSION'

class Gem::Specification
  def dependencies=(gems)
    gems.each{|gem| add_dependency(*gem)}
  end

  def development_dependencies=(gems)
    gems.each{|gem| add_development_dependency(*gem)}
  end
end

Gem::Specification.new do |s|
  s.name = 'switches.rb'
  s.version = Switches::VERSION

  s.summary = "The easiest way to provide switches to a Ruby program."
  s.description = "Switches provides for a nice wrapper to OptionParser to also act as a store for switches supplied."

  s.author = 'thoran'
  s.email = 'code@thoran.com'
  s.homepage = "https://github.com/thoran/switches"
  s.license = 'MIT'

  s.required_ruby_version = ">= 2.7.0"
  s.require_paths = ['lib']

  s.files = [
    'switches.rb.gemspec',
    Dir['lib/**/*.rb'],
    Dir['test/**/*_test.rb'],
    'CHANGELOG',
    'Gemfile',
    'LICENSE',
    'Rakefile',
    'README.md',
  ].flatten

  s.dependencies = [
    'ostruct'
  ]

  s.development_dependencies = [
    'minitest',
    'rake'
  ]

  s.metadata = {
    "bug_tracker_uri" => "https://github.com/thoran/switches/issues",
    "changelog_uri" => "https://github.com/thoran/switches/blob/master/CHANGELOG",
    "source_code_uri" => "https://github.com/thoran/switches",
    "documentation_uri" => "https://github.com/thoran/switches/blob/master/README.md",
  }
end
