# frozen_string_literal: true
require 'rake/testtask'
require 'rubocop/rake_task'
require 'reek/rake/task'

Rake::TestTask.new do |t|
  t.warning = true
  t.description = 'Run "Page" tests'
  t.test_files = FileList['t/page/*.rb', 't/helpers/*.rb']
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

Reek::Rake::Task.new do |t|
  t.source_files = FileList['**/*.rb']
  t.verbose = false
  t.fail_on_error = true
end

task 'everypolitician-data', [:path] do |_, args|
  fixture_path = Pathname.new(File.join('t/fixtures/everypolitician-data', args[:path]))
  mkdir_p(fixture_path.dirname)
  fixture_path.write(open("https://cdn.rawgit.com/everypolitician/everypolitician-data/#{args[:path]}").read)
end
