require_relative '../world'

module Page
  class MissingCountry
    def initialize(slug)
      @slug = slug
    end

    def country
      @country ||= World.new.country(slug)
    end

    private

    attr_reader :slug
  end
end
