Gem::Specification.new do |s|
  s.name = 'switches.rb' # I would have preferred 'switches', but there's a gem with the name of switches.

  s.version = '0.10.1'
  s.date = '2026-08-09'

  s.summary = "The easiest way to provide switches to a Ruby program."
  s.description = "Switches provides for a nice wrapper to OptionParser to also act as a store for switches supplied."
  s.author = 'thoran'
  s.email = 'code@thoran.com'
  s.homepage = "https://github.com/thoran/switches"
  s.license = 'MIT'
  s.required_ruby_version = ">= 2.7.0"

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')

  s.files = [
    'CHANGELOG',
    'Gemfile',
    'LICENSE.txt',
    'Rakefile',
    'README.md',
    'switches.rb.gemspec',
    Dir['lib/**/*.rb'],
    Dir['spec/**/*.rb']
  ].flatten

  s.require_paths = ['lib']

  s.metadata = {
    "bug_tracker_uri" => "https://github.com/thoran/switches/issues",
    "changelog_uri" => "https://github.com/thoran/switches/blob/master/CHANGELOG",
    "source_code_uri" => "https://github.com/thoran/switches",
    "documentation_uri" => "https://github.com/thoran/switches/blob/master/README.md"
  }
end
