# frozen_string_literal: true
require_relative '../world.rb'

module Page
  class SpiderBase
    def world
      World.new.as_json
    end
  end
end
