# frozen_string_literal: true

module Page
  class HouseWikidata
    attr_reader :house

    def initialize(house:)
      @house = house
    end

    def title
      "EveryPolitician: #{country.name} — #{house.name}"
    end

    def country
      house.country
    end

    def wikidata_id
      legislature.wikidata
    end

    def people_with_wikidata
      people_with_and_without_wikidata.first
    end

    def people_without_wikidata
      people_with_and_without_wikidata.last
    end

    private

    def popolo
      house.popolo
    end

    def legislature
      popolo.organizations.find_by(classification: 'legislature')
    end

    def people_with_and_without_wikidata
      popolo.persons.partition(&:wikidata)
    end
  end
end
