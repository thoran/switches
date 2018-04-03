Gem::Specification.new do |s|
  s.name = 'switches.rb' # I would have preferred 'switches', but there's a gem with the name of switches.

  s.version = '0.9.15'
  s.date = '2018-04-03'

  s.summary = "The easiest way to provide switches to a Ruby program."
  s.description = "Switches provides for a nice wrapper to OptionParser to also act as a store for switches supplied."
  s.author = 'thoran'
  s.email = 'code@thoran.com'
  s.homepage = "http://github.com/thoran/switches"

  s.files = [
    'README.md',
    'switches.rb.gemspec',
    Dir['lib/**/*.rb'],
    Dir['spec/**/*.rb']
  ].flatten

  s.require_paths = ['lib']

  s.has_rdoc = false
end
