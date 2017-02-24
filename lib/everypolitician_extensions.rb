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

    CabinetMembership = Struct.new(:person_id, :label, :start_date, :end_date)

    def cabinet_memberships
      unstable_positions.reject { |p| p[:start_date].nil? }.map do |p|
        CabinetMembership.new(p[:id], p[:position], p[:start_date], p[:end_date])
      end
    end

    private

    def unstable_positions
      CSV.parse(unstable_positions_csv, converters: nil, headers: true, header_converters: :symbol)
    end

    def unstable_positions_csv
      open(unstable_positions_csv_url).read
    end

    def unstable_positions_csv_url
      names_url.gsub(/names\.csv$/, 'unstable/positions.csv')
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

    def cabinet_memberships
      @cabinet_memberships ||= legislature.cabinet_memberships.select do |m|
        m.start_date >= start_date.to_s && (m.end_date.nil? || m.end_date <= end_date.to_s)
      end
    end

    def people
      @people ||= memberships.map(&:person).uniq(&:id)
    end

    def top_identifiers
      @top_identifiers ||= people
                           .map(&:identifiers)
                           .compact
                           .flatten
                           .reject { |i| i[:scheme] == 'everypolitician_legacy' }
                           .group_by { |i| i[:scheme] }
                           .sort_by { |s, ids| [-ids.size, s] }
                           .map { |s, _ids| s }
    end
  end

  module MembershipExtension
    # The political group (party / faction) this membership is held on behalf of
    # @return [Everypolitician::Popolo::Organization]
    def group
      popolo.organizations.find_by(id: on_behalf_of_id)
    end

    # The area that this membership belongs to
    # @return [Everypolitician::Popolo::Area]
    def area
      popolo.areas.find_by(id: area_id)
    end
  end
end

EveryPolitician::Country.include EveryPolitician::CountryExtension
EveryPolitician::Legislature.include EveryPolitician::LegislatureExtension
EveryPolitician::LegislativePeriod.include EveryPolitician::LegislativePeriodExtension
EveryPolitician::Popolo::Membership.include Everypolitician::MembershipExtension
