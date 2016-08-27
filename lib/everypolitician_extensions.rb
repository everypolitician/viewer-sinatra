# frozen_string_literal: true
require 'everypolitician'
require 'open-uri'
require 'fileutils'

module EveryPolitician
  module CountryExtension
    def person_count
      legislatures.map(&:person_count).inject(:+)
    end
  end

  module LegislatureExtension
    # UK.legislature('Commons').term(65)
    def term(termid)
      after, current, before = [nil, legislative_periods, nil]
                               .flatten
                               .each_cons(3)
                               .find do |_, term, _|
        term.id.split('/').last == termid.to_s
      end
      current.define_singleton_method(:prev) { before }
      current.define_singleton_method(:next) { after }
      current
    end
  end
end

EveryPolitician::Country.include EveryPolitician::CountryExtension
EveryPolitician::Legislature.include EveryPolitician::LegislatureExtension
