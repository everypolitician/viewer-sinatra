# frozen_string_literal: true
require_relative '../world'
require_relative '../everypolitician_extensions'

module Page
  class Home
    def initialize(index:)
      @index = index
    end

    def title
      "EveryPolitician: Political data for #{countries.count} countries"
    end

    def countries
      index.countries
    end

    def total_people
      legislatures.map(&:person_count).inject(:+)
    end

    def total_statements
      legislatures.map(&:statement_count).inject(:+)
    end

    def world
      world_json.each do |slug, country|
        country[:totalPeople] = index.country(slug.to_s).person_count rescue 0
      end
    end

    private

    attr_reader :index

    def legislatures
      @_legislatures ||= countries.flat_map(&:legislatures)
    end

    def world_json
      World.new.as_json
    end
  end
end
