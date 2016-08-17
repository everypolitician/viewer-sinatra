require 'everypolitician'

module Page
  class Country
    attr_reader :title
    def initialize(slug)
      @slug    = slug
      @title   = "EveryPolitician: #{country[:name]}" if country
    end

    def country
      EveryPolitician.country(@slug)
    end
  end
end
