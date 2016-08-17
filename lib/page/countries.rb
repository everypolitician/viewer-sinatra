require 'everypolitician'
require_relative '../world'

module Page
  class Countries
    def countries
      @countries ||= EveryPolitician.countries
    end

    def download_url
      @download_url ||= EveryPolitician.countries_json
    end

    def world
      @world ||= World.new.as_json
    end
  end
end
