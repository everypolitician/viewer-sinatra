# frozen_string_literal: true
module EveryPolitician
  module CountryExtension
    def person_count
      legislatures.map(&:person_count).inject(:+)
    end
  end
end

EveryPolitician::Country.include EveryPolitician::CountryExtension
