# frozen_string_literal: true
source 'https://rubygems.org'

ruby '2.3.1'

gem 'dotenv'
gem 'everypolitician', '~> 0.18.0', git: 'https://github.com/everypolitician/everypolitician-ruby.git'
gem 'everypolitician-popolo', git: 'https://github.com/everypolitician/everypolitician-popolo.git'
gem 'iso_country_codes'
gem 'json'
gem 'nokogiri', '>= 1.6.7'
gem 'octokit'
gem 'puma'
gem 'rack', '~> 1.6.2'
gem 'rake'
gem 'redcarpet', '~> 3.2.3'
gem 'require_all'
gem 'sass'
gem 'sinatra'
gem 'yajl-ruby', require: 'yajl'

group :test do
  gem 'minitest'
  gem 'pry'
  gem 'rack-test'
  gem 'webmock'
  gem 'bundler-audit'
end

group :quality do
  gem 'flog'
  gem 'reek'
  gem 'rubocop'
end
