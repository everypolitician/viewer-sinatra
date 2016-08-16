module Page
  class Country
    attr_reader :country, :title, :missing
    def initialize(country, all_countries, world)
      @country = all_countries.find { |c| c[:url] == country }
      if @country
        @title = "EveryPolitician: #{@country[:name]}"
      else
        @missing = world[country.to_sym]
      end
    end
  end
end
