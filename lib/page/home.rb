# frozen_string_literal: true
require_relative '../world'
require_relative '../everypolitician_extensions'

module Page
  class Home
    def initialize(index:)
      @index = index
    end

    def title
      "EveryPolitician: Political data for #{countries_with_data.count} countries"
    end

    def total_people
      legislatures.map(&:person_count).inject(:+)
    end

    def total_statements
      legislatures.map(&:statement_count).inject(:+)
    end

    def all_countries
      world.countries
    end

    def countries_with_data
      all_countries.map(&:epcountry).compact
    end

    private

    attr_reader :index

    def legislatures
      @_legislatures ||= countries_with_data.flat_map(&:legislatures)
    end

    def world
      World.new(index: index)
    end
  end
end
