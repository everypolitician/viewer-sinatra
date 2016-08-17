require_relative '../world.rb'

module Page
  class AllCountries
    attr_accessor :world
    def initialize
      @world = World.new.as_json.to_a
    end
  end
end
