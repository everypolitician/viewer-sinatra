# frozen_string_literal: true

module Page
  class Country
    attr_reader :country

    def initialize(country:)
      @country = country
    end

    def title
      "EveryPolitician: #{country.name}"
    end
  end
end
