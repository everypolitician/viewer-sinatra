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
  t.name = 'test:extensions'
  t.warning = false
  t.verbose = true
  t.description = 'Run "Everypolitician extensions" tests'
  t.test_files = FileList['t/everypolitician_extensions/**/*.rb']
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
  require 'everypolitician'
  index = Everypolitician::Index.new(index_url: 't/fixtures/d8a4682f-countries.json')
  legislature = index.countries.flat_map(&:legislatures).find do |l|
    args[:path].start_with?("data/#{l.directory}")
  end
  fixture_path = Pathname.new(File.join('t/fixtures/everypolitician-data', args[:path]))
  mkdir_p(fixture_path.dirname)
  fixture_path.write(open("https://cdn.rawgit.com/everypolitician/everypolitician-data/#{legislature.sha}/#{args[:path]}").read)
end

# Check for known vulnerabilities in Gemfile.lock

require 'bundler/audit/task'
Bundler::Audit::Task.new

task default: ['test:all', 'rubocop', 'bundle:audit']
