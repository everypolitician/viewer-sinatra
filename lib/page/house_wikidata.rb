# frozen_string_literal: true

module Page
  class HouseWikidata
    def initialize(country:, house:, index:)
      @country_slug = country
      @house_slug = house
      @index = index
    end

    def title
      "EveryPolitician: #{country.name} — #{house.name}"
    end

    def country
      index.country(country_slug)
    end

    def house
      country.legislature(house_slug)
    end

    # TODO: we shouldn't be passing raw Popolo, only what's needed
    def popolo
      house.popolo
    end

    private

    attr_reader :house_slug, :country_slug, :index
  end
end
