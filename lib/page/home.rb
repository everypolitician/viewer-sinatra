# frozen_string_literal: true
require_relative '../world'
require_relative '../everypolitician_extensions'

module Page
  # The Home Page of the site: {http://www.everypolitician.org/}
  class Home
    # @param index [EveryPolitician::Index]
    def initialize(index:)
      @index = index
    end

    # The Page title
    # @return [String]
    def title
      "EveryPolitician: Political data for #{countries_with_data.count} countries"
    end

    # The total number of people we have across all legislatures.
    # @return [Integer]
    def total_people
      legislatures.map(&:person_count).inject(:+)
    end

    # The total number of statements in all the Popolo data files.
    # @return [Integer]
    def total_statements
      legislatures.map(&:statement_count).inject(:+)
    end

    # A list of every Country we know exists, whether we have data for
    # it or not
    # @return [Array<World::Country>]
    def all_countries
      world.countries
    end

    # A list of every Country we have data for
    # @return [Array<EveryPolitician::Country>]
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
