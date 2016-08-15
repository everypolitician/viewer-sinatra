require_relative '../../lib/page/needed'
require 'minitest/autorun'
require 'octokit'
require 'pry'
require 'vcr'

VCR.configure do |config|
  config.allow_http_connections_when_no_cassette = true
  config.cassette_library_dir = 't/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.ignore_request do |req|
    req[:uri].include? 'https://cdn.rawgit.com/everypolitician/everypolitician-data'
  end
end

describe 'Needed' do
  subject do
    Page::Needed.new
  end

  it 'should return a list of countries labeled to_find' do
    VCR.use_cassette('octokit - test to_find') do
      list = subject.to_find
      labels = ['New Country', 'To Find']
      labels.must_include list.first[:labels].first[:name]
    end
  end

  it 'should return a list of countries to_scrape' do
    VCR.use_cassette('octokit - test to_scrape') do
      subject.to_scrape.size.must_equal 0
    end
  end

  it 'should return a list of countries labeled "New Country,3 - WIP"' do
    VCR.use_cassette('octokit - test to_finish') do
      subject.to_finish.size.must_equal 0
    end
  end
end
