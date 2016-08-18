require 'minitest/autorun'

module Minitest
  class Spec
    def known_countries_json_url
      'https://cdn.rawgit.com/everypolitician/everypolitician-data/d8a4682f/countries.json'
    end

    def index_at_known_sha
      @index_at_known_sha ||= EveryPolitician::Index.new(index_url: known_countries_json_url)
    end
  end
end
