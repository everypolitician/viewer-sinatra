# frozen_string_literal: true
require_relative '../world'

module Page
  class MissingCountry
    def initialize(country:)
      @slug = country
    end

    def title
      "EveryPolitician: #{country.name}"
    end

    def country
      @country ||= World.new.country(slug)
    end

    private

    attr_reader :slug
  end
end
