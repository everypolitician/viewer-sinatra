# frozen_string_literal: true

module Page
  class Country
    def initialize(country:, index:)
      @slug  = country
      @index = index
    end

    def title
      "EveryPolitician: #{country.name}"
    end

    def country
      index.country(slug)
    end

    private

    attr_reader :slug, :index
  end
end
