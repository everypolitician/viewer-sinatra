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

    def more_houses?
      country.legislatures.count > 1
    end

    def other_houses
      country.legislatures.reject { |legislature| legislature.slug == house.slug }
    end

    private

    attr_reader :index
  end
end
