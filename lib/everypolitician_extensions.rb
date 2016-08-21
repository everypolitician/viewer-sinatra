# frozen_string_literal: true
require 'everypolitician'

module EveryPolitician
  module CountryExtension
    def person_count
      legislatures.map(&:person_count).inject(:+)
    end
  end
end

EveryPolitician::Country.include EveryPolitician::CountryExtension
