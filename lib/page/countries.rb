require 'everypolitician'
require_relative '../world'

module Page
  class Countries
    def initialize(index:)
      @index = index
    end

    def countries
      index.countries
    end

    def download_url
      index.index_url
    end

    def world
      @world ||= World.new.as_json
    end

    private

    attr_reader :index
  end
end
