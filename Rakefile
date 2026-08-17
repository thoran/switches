# Rakefile

require 'rake/testtask'

Rake::TestTask.new(:spec) do |t|
  t.test_files = ['spec/all.rb']
end

task default: :spec

desc "Show version"
task :version do
  puts "switches.rb #{Gem::Specification.load('switches.rb.gemspec').version}"
end
