# Rakefile

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/**/*_test.rb']
end

task default: :test

desc "Show version"
task :version do
  puts "switches.rb #{Gem::Specification.load('switches.rb.gemspec').version}"
end
