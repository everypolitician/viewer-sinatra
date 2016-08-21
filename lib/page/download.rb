# frozen_string_literal: true

module Page
  class Download
    def initialize(country:, index:)
      @country_slug = country
      @index = index
    end

    def download_url
      index.index_url
    end

    def country
      index.country(country_slug)
    end

    private

    attr_reader :country_slug, :index
  end
end
