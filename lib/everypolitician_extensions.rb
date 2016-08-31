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

  module LegislativePeriodExtension
    def memberships
      @mems ||= legislature.popolo.memberships.select do |mem|
        mem.legislative_period_id == id
      end
    end

    def memberships_at_end
      memberships.select do |mem|
        mem.end_date.to_s.empty? || mem.end_date == end_date
      end
    end
  end

  module MembershipExtension
    def group
      popolo.organizations.find_by(id: on_behalf_of_id)
    end

    def area
      popolo.areas.find_by(id: area_id)
    end

    def group_name
      group.name.to_s.downcase == 'unknown' ? '' : group.name
    end

    def area_name
      area.name if area_id
    end
  end
end

EveryPolitician::Country.include EveryPolitician::CountryExtension
EveryPolitician::Legislature.include EveryPolitician::LegislatureExtension
EveryPolitician::LegislativePeriod.include EveryPolitician::LegislativePeriodExtension
EveryPolitician::Popolo::Membership.include EveryPolitician::MembershipExtension
