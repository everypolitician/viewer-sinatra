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
      popolo.popolo[:meta][:sources].map { |s| CGI.unescape(s) }
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
      @people ||= people_for_current_term.sort_by(&:sort_name).map do |person|
        PersonCard.new(
          person:          person,
          proxy_image:     image_proxy_url(person.id),
          memberships:     person_memberships(person),
          top_identifiers: top_identifiers
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

    def top_identifiers
      @tidx ||= people_for_current_term
                .map(&:identifiers)
                .compact
                .flatten
                .reject { |i| i[:scheme] == 'everypolitician_legacy' }
                .group_by { |i| i[:scheme] }
                .sort_by { |_s, ids| -ids.size }
                .map { |s, _ids| s }
                .take(3)
    end

    def person_memberships(person)
      membership_lookup[person.id].each do |mem|
        area = area_lookup[mem.area_id].first.name if mem.area_id
        group = member_group(mem)
        mem.define_singleton_method(:group) { group || '' }
        mem.define_singleton_method(:area)  { area  || '' }
      end
    end

    def member_group(member)
      group = org_lookup[member.on_behalf_of_id].first.name if member.on_behalf_of_id
      group = '' if group.to_s.downcase == 'unknown'
      group
    end

    def image_proxy_url(id)
      'https://mysociety.github.io/politician-image-proxy' \
      "/#{country.slug}/#{house.slug}/#{id}/140x140.jpeg"
    end

    # Caches for faster lookup
    def membership_lookup
      @membership_lookup ||= current_term_memberships.group_by(&:person_id)
    end

    def area_lookup
      @area_lookup ||= popolo.areas.group_by(&:id)
    end

    def org_lookup
      @org_lookup ||= popolo.organizations.group_by(&:id)
    end

    def current_term_memberships
      @ctm ||= term.memberships
    end

    def current_term_people_ids
      @ctpids ||= Set.new(current_term_memberships.map(&:person_id))
    end

    def people_for_current_term
      @pct ||= popolo.persons.select { |p| current_term_people_ids.include?(p.id) }
    end
  end
end
