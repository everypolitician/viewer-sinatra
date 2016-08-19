# frozen_string_literal: true
require 'minitest/autorun'
require 'webmock/minitest'

module Minitest
  class Spec
    def setup
      stub_request(:get, 'https://cdn.rawgit.com/everypolitician/everypolitician-data/d8a4682f/countries.json')
        .to_return(body: File.read('t/fixtures/d8a4682f-countries.json'))
    end

    def known_countries_json_url
      'https://cdn.rawgit.com/everypolitician/everypolitician-data/d8a4682f/countries.json'
    end

    def index_at_known_sha
      @index_at_known_sha ||= EveryPolitician::Index.new(index_url: known_countries_json_url)
    end
  end
end
