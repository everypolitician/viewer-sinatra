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
      wikidata_json[:claims][:P1342].first[:mainsnak][:datavalue][:value][:amount].to_i
    end

    def wikidata
      legislature.wikidata
    end

    # FIXME: This class should not know about the outside world
    def wikidata_json
      raw_json = JSON.parse(
        open("https://www.wikidata.org/wiki/Special:EntityData/#{wikidata}.json").read,
        symbolize_names: true
      )
      raw_json[:entities][wikidata.to_sym]
    end

    def people_with_and_without_wikidata
      @with_and_without_array ||= popolo.persons.partition(&:wikidata)
    end
  end
end
