# frozen_string_literal: true
require 'everypolitician'
require_relative '../everypolitician_extensions'
require_relative '../person_cards'

module Page
  class TermTable
    def initialize(term:)
      @term = term
    end

    def title
      parts = [country.name, house.name, current_term.name]
      "EveryPolitician: #{parts.join(' - ')}"
    end

    def data_sources
      popolo.popolo[:meta][:sources]
    end

    def country
      house.country
    end

    def house
      term.legislature
    end

    def terms
      house.legislative_periods
    end

    def next_term
      term.next
    end

    def prev_term
      term.prev
    end

    def current_term
      term
    end

    SeatCount = Struct.new(:group_id, :name, :member_count)
    def group_data
      @group_data ||= term
                      .memberships_at_end
                      .group_by(&:on_behalf_of_id)
                      .map     { |group_id, mems| [org_lookup[group_id].first, mems] }
                      .sort_by { |group, mems| [-mems.count, group.name] }
                      .map     { |group, mems| SeatCount.new(group.id.split('/').last, group.name, mems.count) }

      @group_data = [] if @group_data.length == 1
      @group_data
    end

    def people
      @people ||= term.people.sort_by { |e| [e.sort_name, e.name] }.map do |person|
        PersonCard.new(
          person: person,
          term:   term,
          positions: positions.select { |pos| pos[:id] == person.id }
        )
      end
    end

    CARDS = %i(social bio contacts identifiers).freeze
    Percentages = Struct.new(*CARDS)
    def percentages
      pc = ->(card) { ((people.count { |p| p.send(card.to_s).any? } / people.count.to_f) * 100).floor }
      Percentages.new(*CARDS.map { |card| pc.call(card) })
    end

    private

    attr_reader :term

    def popolo
      @popolo ||= house.popolo
    end

    def positions
      @positions ||= CSV.parse(open(house.names_url.gsub(/names\.csv$/, 'unstable/positions.csv')).read, converters: nil, headers: true, header_converters: :symbol).select { |pos| pos[:type] == 'cabinet' }
    end

    # Caches for faster lookup
    def area_lookup
      @area_lookup ||= popolo.areas.group_by(&:id)
    end

    def org_lookup
      @org_lookup ||= popolo.organizations.group_by(&:id)
    end
  end
end
