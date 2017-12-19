# frozen_string_literal: true

require 'wikidata'

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

    def seat_count
      wikidata_seat_count
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

    def wikidata_seat_count
      wikidata.property('P1342')&.amount&.to_i
    end

    def wikidata
      Wikidata::Item.find(wikidata_id)
    end

    def people_with_and_without_wikidata
      @with_and_without_array ||= popolo.persons.partition(&:wikidata)
    end
  end
end
