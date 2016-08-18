require_relative '../world.rb'

module Page
  class AllCountries
    attr_accessor :world
    def initialize
      @world = World.new.as_json
    end
  end
end
