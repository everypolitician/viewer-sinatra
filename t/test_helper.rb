# frozen_string_literal: true
ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'nokogiri'
require 'pathname'
require 'rack/test'
require 'pry'
require 'webmock/minitest'
require 'everypolitician'

module Minitest
  class Spec
    include Rack::Test::Methods

    def app
      Sinatra::Application
    end

    before do
      cj_file = %r{#{cdn}/#{ep_repo}/\w+/countries.json}
      fixture = Pathname.new('t/fixtures/d8a4682f-countries.json')
      WebMock.stub_request(:get, cj_file) .to_return(body: fixture.read)
    end

    def index_at_known_sha
      @shaidx ||= EveryPolitician::Index.new(index_url: countries_json_url)
    end

    def stub_everypolitician_data_request(path)
      stub_request(:get, "https://cdn.rawgit.com/everypolitician/everypolitician-data/#{path}")
        .to_return(body: File.read("t/fixtures/everypolitician-data/#{path}"))
    rescue Errno::ENOENT => error
      raise "#{error.message}\n\nTo download this fixture run the following\n\n\tbundle exec rake 'everypolitician-data[#{path}]'\n"
    end

    private

    def cdn
      'https://cdn.rawgit.com'
    end

    def ep_repo
      'everypolitician/everypolitician-data'
    end

    def countries_json_url
      URI.join(cdn, ep_repo + '/', 'd8a4682f/countries.json').to_s
    end
  end
end
