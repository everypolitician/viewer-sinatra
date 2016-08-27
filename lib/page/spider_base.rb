# frozen_string_literal: true
require_relative '../world.rb'

module Page
  class SpiderBase
    def title
      'EveryPolitician: Robots Start Here'
    end

    def countries
      World.new.countries
    end
  end
end
