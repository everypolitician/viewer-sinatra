# frozen_string_literal: true

module Page
  class Download
    attr_reader :country

    def initialize(country:, index:)
      @country = country
      @index = index
    end

    def title
      "EveryPolitician: #{country.name}"
    end

    def download_url
      index.index_url
    end

    private

    attr_reader :index
  end
end
