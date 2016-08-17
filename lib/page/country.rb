require 'everypolitician'

module Page
  class Country
    def initialize(slug)
      @slug = slug
    end

    def country
      @country ||= EveryPolitician.country(slug)
    end

    def title
      "EveryPolitician: #{country[:name]}" if country
    end

    private

    attr_reader :slug
  end
end
