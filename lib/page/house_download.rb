# frozen_string_literal: true

module Page
  class HouseDownload
    attr_reader :house

    def initialize(house:, index:)
      @house = house
      @index = index
    end

    def country
      house.country
    end

    def title
      "EveryPolitician: #{country.name} - #{house.name}"
    end

    def legislative_periods
      house.legislative_periods
    end

    def download_url
      index.index_url
    end

    private

    attr_reader :index
  end
end
