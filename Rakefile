# frozen_string_literal: true

require 'rake/testtask'
require 'rubocop/rake_task'
require 'reek/rake/task'

Rake::TestTask.new do |t|
  t.name = 'test:page'
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
  t.warning = false
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

# Check for known vulnerabilities in Gemfile.lock

require 'bundler/audit/task'
Bundler::Audit::Task.new

require_relative 'lib/static_site_generator.rb'
desc 'Build static site pages that rely on JavaScript'
task :generate_static_site_javascript_pages, [:base_url] do |_, args|
  base_url = args.fetch(:base_url, 'http://localhost:4567')
  javascript_pages_to_scrape = ["#{base_url}/needed.html"]
  StaticSiteGenerator.new(urls: javascript_pages_to_scrape).build
end

task default: ['test', 'rubocop', 'bundle:audit']
