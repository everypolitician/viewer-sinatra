# frozen_string_literal: true
require 'everypolitician'
require_relative '../everypolitician_extensions'
require_relative '../person_cards'
require_relative '../term_statistics'

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

    def group_data
      term_statistics.group_data
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

    def percentages
      term_statistics.percentages
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
        group = org_lookup[mem.on_behalf_of_id].first.name if mem.on_behalf_of_id
        group = '' if group.to_s.downcase == 'unknown'
        area = area_lookup[mem.area_id].first.name if mem.area_id
        mem.define_singleton_method(:group) { group || '' }
        mem.define_singleton_method(:area)  { area  || '' }
      end
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

    def term_statistics
      @term_statistics ||= TermStatistics.new(term: term, org_lookup: org_lookup, people: people)
    end
  end
end
