require 'everypolitician'

module Page
  class Country
    attr_reader :country, :title
    def initialize(country)
      @country = EveryPolitician.country(country)
      @title   = "EveryPolitician: #{@country[:name]}" if @country
    end
  end
end
