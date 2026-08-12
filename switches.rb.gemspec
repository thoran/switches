require_relative './lib/Switches/VERSION'

class Gem::Specification
  def development_dependencies=(gems)
    gems.each{|gem| add_development_dependency(*gem)}
  end
end

Gem::Specification.new do |s|
  s.name = 'switches.rb' # I would have preferred 'switches', but there's a gem with the name of switches.
  s.version = Switches::VERSION

  s.summary = "The easiest way to provide switches to a Ruby program."
  s.description = "Switches provides for a nice wrapper to OptionParser to also act as a store for switches supplied."

  s.author = 'thoran'
  s.email = 'code@thoran.com'
  s.homepage = "https://github.com/thoran/switches"
  s.license = 'MIT'

  s.required_ruby_version = ">= 2.7.0"

  s.development_dependencies = [
    'rake',
    'rspec'
  ]

  s.files = [
    'CHANGELOG',
    'Gemfile',
    'LICENSE.txt',
    'Rakefile',
    'README.md',
    'switches.rb.gemspec',
    Dir['lib/**/*.rb'],
    Dir['spec/**/*.rb'],
  ].flatten

  s.require_paths = ['lib']

  s.metadata = {
    "bug_tracker_uri" => "https://github.com/thoran/switches/issues",
    "changelog_uri" => "https://github.com/thoran/switches/blob/master/CHANGELOG",
    "source_code_uri" => "https://github.com/thoran/switches",
    "documentation_uri" => "https://github.com/thoran/switches/blob/master/README.md",
  }
end
