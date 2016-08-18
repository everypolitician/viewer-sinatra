require 'everypolitician'
require 'json'
require_relative '../world'

module Page
  class Home
    attr_reader :index
    attr_reader :countries

    def initialize(index: Everypolitician::Index.new)
      @index = index
      @countries = index.countries
    end

    def total_people
      legislatures.map(&:person_count).inject(:+)
    end

    def total_statements
      legislatures.map(&:statement_count).inject(:+)
    end

    def world
      world_json.each do |slug, country|
        country[:totalPeople] = index.country(slug.to_s).legislatures.map(&:person_count).inject(:+) rescue 0
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
