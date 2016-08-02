require 'rake/testtask'
require 'rubocop/rake_task'

Rake::TestTask.new do |t|
  t.pattern = 't/**/*.rb'
end

RuboCop::RakeTask.new
