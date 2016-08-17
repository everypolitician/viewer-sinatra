require 'everypolitician'

module Page
  class Country
    def initialize(slug)
      @slug = slug
    end

    def country
      EveryPolitician.country(@slug)
    end

    def title
      "EveryPolitician: #{country[:name]}" if country
    end
  end
end
