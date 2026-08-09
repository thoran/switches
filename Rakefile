# Rakefile

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/all.rb'
end

task default: :spec

desc "Show version"
task :version do
  puts "switches.rb #{Gem::Specification.load('switches.rb.gemspec').version}"
end
