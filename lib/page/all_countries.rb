require_relative '../world.rb'

module Page
  class AllCountries
    def world
      World.new.as_json
    end
  end
end
