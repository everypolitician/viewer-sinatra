require_relative '../../lib/popolo_helper.rb'

module Page
  class HouseWikidata
    def initialize(slug, house)
      @house = house
      @slug = slug
    end

    def country
      EveryPolitician.country(@slug)
    end

    def house
      country[:legislatures].find { |h| h[:slug].downcase == @house.downcase }
    end

    def last_sha
      house[:sha]
    end

    def popolo
      popolo_file = EveryPolitician::GithubFile.new(house[:popolo], last_sha)
      JSON.parse(popolo_file.raw, symbolize_names: true)
    end

    def page_title
      "EveryPolitician: #{country[:name]} — #{house[:name]}"
    end
  end
end
