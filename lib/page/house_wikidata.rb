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

    def people_with_wikidata
      people_with_and_without_wikidata.first
    end

    def people_without_wikidata
      people_with_and_without_wikidata.last
    end

    private

    attr_reader :house_slug, :country_slug, :index

    def popolo
      house.popolo
    end

    def people_with_and_without_wikidata
      @with_and_without_array ||= popolo.persons.partition(&:wikidata)
    end
  end
end
