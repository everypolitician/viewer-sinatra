require 'everypolitician'
require 'json'
require_relative '../world'

module Page
  class Home
    def countries
      @_countries ||= EveryPolitician.countries
    end

    def total_people
      legislatures.map(&:person_count).inject(:+)
    end

    def total_statements
      legislatures.map(&:statement_count).inject(:+)
    end

    def world
      world_json.each do |slug, country|
        country[:totalPeople] = EveryPolitician.country(slug.to_s).legislatures.map(&:person_count).inject(:+) rescue 0
      end
    end

    private

    def legislatures
      @_legislatures ||= countries.flat_map(&:legislatures)
    end

    def world_json
      World.new.as_json
    end
  end
end
