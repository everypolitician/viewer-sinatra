require_relative '../../lib/popolo_helper.rb'

module Page
  class HouseWikidata
    def initialize(country_slug, house_slug)
      @house_slug = house_slug
      @country_slug = country_slug
    end

    def country
      EveryPolitician.country(country_slug)
    end

    def house
      country[:legislatures].find { |h| h[:slug].downcase == house_slug.downcase }
    end

    def popolo
      popolo_file = EveryPolitician::GithubFile.new(house[:popolo], last_sha)
      JSON.parse(popolo_file.raw, symbolize_names: true)
    end

    def page_title
      "EveryPolitician: #{country[:name]} — #{house[:name]}"
    end

    private

    attr_reader :house_slug, :country_slug
    def last_sha
      house[:sha]
    end
  end
end
