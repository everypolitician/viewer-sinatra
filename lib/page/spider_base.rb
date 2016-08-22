# frozen_string_literal: true
require_relative '../world.rb'

module Page
  class SpiderBase
    def title
      'EveryPolitician: Robots Start Here'
    end

    def countries
      world.countries
    end

    private

    def world
      World.new
    end
  end
end
