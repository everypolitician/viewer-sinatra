require 'rake/testtask'
require 'rubocop/rake_task'

Rake::TestTask.new do |t|
  t.warning = true
  t.test_files = FileList['t/page/*.rb']
end

Rake::TestTask.new do |t|
  t.name = 'test:web'
  t.warning = false
  t.verbose = true
  t.test_files = FileList['t/web/*.rb']
end

Rake::TestTask.new do |t|
  t.name = 'test:all'
  t.verbose = true
  t.test_files = FileList['t/**/*.rb']
end

RuboCop::RakeTask.new
