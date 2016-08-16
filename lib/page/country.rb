module Page
  class Country
    attr_reader :country, :title
    def initialize(country, all_countries)
      @country = all_countries.find { |c| c[:url] == country }
      @title = "EveryPolitician: #{@country[:name]}" if @country
    end
  end
end
