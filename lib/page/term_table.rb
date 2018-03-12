# frozen_string_literal: true

require 'everypolitician'
require_relative '../everypolitician_extensions'
require_relative '../person_cards'

module Page
  # Page showing members for an individual term of a legislature.
  class TermTable
    # @param term [EveryPolitician::LegislativePeriod]
    def initialize(term:)
      @term = term
    end

    # The Page title
    # @return [String]
    def title
      parts = [country.name, house.name, current_term.name]
      "EveryPolitician: #{parts.join(' - ')}"
    end

    # A list of URLs where the data for this term came from.
    # @return [Array<String>]
    def data_sources
      popolo.popolo[:meta][:sources]
    end

    # The country that this term relates to
    # @return [EveryPolitician::Country]
    def country
      house.country
    end

    # The legislature that this term relates to
    # @return [EveryPolitician::Legislature]
    def house
      term.legislature
    end

    # Other terms for the legislature the current term relates to
    # @return [Array<EveryPolitician::LegislativePeriod>]
    def terms
      house.legislative_periods
    end

    # The next (newer) term for the current legislature
    # @return [EveryPolitician::LegislativePeriod]
    def next_term
      term.next
    end

    # The previous (older) term for the current legislature
    # @return [EveryPolitician::LegislativePeriod]
    def prev_term
      term.prev
    end

    # The current term that this class is wrapping
    # @return [EveryPolitician::LegislativePeriod]
    def current_term
      term
    end

    # Represents a count of seats/members for a given group.
    SeatCount = Struct.new(:group_id, :name, :member_count)

    # A list of groups that we know about and their seat/member counts
    # @return [Array<SeatCount>]
    def group_data
      return [] if complete_group_data.length == 1
      complete_group_data
    end

    # A list of people that held a membership at some point during this term
    # @return [Array<PersonCard>]
    def people
      @people ||= term.people.sort_by { |e| [e.sort_name, e.name] }.map do |person|
        PersonCard.new(
          person: person,
          term:   term
        )
      end
    end

    # A list of symbols representing the cards we show for a person.
    CARDS = %i[social bio contacts identifiers].freeze

    # Represents the percentages of information we have for each card type.
    Percentages = Struct.new(*CARDS)

    # The known percentages for the various types of data we display on the site.
    # @return [Percentages]
    def percentages
      Percentages.new(*CARDS.map { |card| ((people_with(card) / people.count.to_f) * 100).floor })
    end

    private

    attr_reader :term

    def popolo
      @popolo ||= house.popolo
    end

    # Caches for faster lookup
    def area_lookup
      @area_lookup ||= popolo.areas.group_by(&:id)
    end

    def org_lookup
      @org_lookup ||= popolo.organizations.group_by(&:id)
    end

    def people_with(datatype)
      people.count { |p| p.send(datatype.to_s).any? }
    end

    def complete_group_data
      group_memberships
        .sort_by { |group, mems| [-mems.count, group.name] }
        .map     { |group, mems| SeatCount.new(group.id.split('/').last, group.name, mems.count) }
    end

    def group_memberships
      term.memberships_at_end
          .group_by(&:on_behalf_of_id)
          .map { |group_id, mems| [org_lookup[group_id].first, mems] }
    end
  end
end
