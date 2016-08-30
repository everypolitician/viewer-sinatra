# frozen_string_literal: true

module Page
  class HouseDownload
    attr_reader :country, :house

    def initialize(country:, house:, index:)
      @country = country
      @house   = house
      @index   = index
    end

    def title
      "EveryPolitician: #{country.name} - #{house.name}"
    end

    def legislative_periods
      house.legislative_periods
    end

    def download_url
      index.index_url
    end

    private

    attr_reader :index
  end
end
