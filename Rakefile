# frozen_string_literal: true
require 'rake/testtask'
require 'rubocop/rake_task'

Rake::TestTask.new do |t|
  t.warning = true
  t.description = 'Run "Page" tests'
  t.test_files = FileList['t/page/*.rb', 't/helpers/*.rb']
  t.libs << 't'
end

Rake::TestTask.new do |t|
  t.name = 'test:subviews'
  t.warning = true
  t.description = 'Run "Subview" tests'
  t.test_files = FileList['t/subviews/*.rb', 't/helpers/*.rb']
  t.libs << 't'
end

Rake::TestTask.new do |t|
  t.name = 'test:web'
  t.warning = false
  t.verbose = true
  t.description = 'Run "Web" tests (slow)'
  t.test_files = FileList['t/web/**/*.rb']
  t.libs << 't'
end

Rake::TestTask.new do |t|
  t.name = 'test:all'
  t.verbose = true
  t.description = 'Run all tests (slow)'
  t.test_files = FileList['t/**/*.rb']
  t.libs << 't'
end

RuboCop::RakeTask.new
