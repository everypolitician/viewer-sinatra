# frozen_string_literal: true
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

    def missing_countries
      world.count - countries.count
    end

    private

    attr_reader :index

    def world
      @world ||= World.new.as_json
    end
  end
end
