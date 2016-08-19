# frozen_string_literal: true
ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'vcr'
require 'rack/test'
require 'nokogiri'

VCR.configure do |config|
  config.cassette_library_dir = 't/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.filter_sensitive_data('<GITHUB_ACCESS_TOKEN>') { ENV['GITHUB_ACCESS_TOKEN'] }
end

module Minitest
  class Spec
    include Rack::Test::Methods

    def app
      Sinatra::Application
    end

    before do
      WebMock.stub_request(:get, %r{https://cdn.rawgit.com/everypolitician/everypolitician-data/\w+?/countries.json})
             .to_return(body: File.read('t/fixtures/d8a4682f-countries.json'))
      VCR.insert_cassette(name)
    end

    after do
      VCR.eject_cassette
    end

    def known_countries_json_url
      'https://cdn.rawgit.com/everypolitician/everypolitician-data/d8a4682f/countries.json'
    end

    def index_at_known_sha
      @index_at_known_sha ||= EveryPolitician::Index.new(index_url: known_countries_json_url)
    end
  end
end
