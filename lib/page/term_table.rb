# frozen_string_literal: true
require 'everypolitician'
require_relative '../everypolitician_extensions'

module Page
  class TermTable
    def initialize(country_slug:, house_slug:, term_id:, index:)
      @country_slug = country_slug
      @house_slug   = house_slug
      @term_id      = term_id
      @index        = index
    end

    def title
      parts = [country.name, house.name, current_term.name]
      "EveryPolitician: #{parts.join(' - ')}"
    end

    def data_sources
      popolo.popolo[:meta][:sources].map { |s| CGI.unescape(s) }
    end

    def country
      index.country(country_slug)
    end

    def house
      country.legislatures.find do |house|
        house.slug.downcase == house_slug.downcase
      end
    end

    def terms
      house.legislative_periods
    end

    def next_term
      hashed_adjacent_terms[:prev_term]
    end

    def prev_term
      hashed_adjacent_terms[:next_term]
    end

    def current_term
      hashed_adjacent_terms[:current_term]
    end

    def csv_url
      current_term[:csv_url]
    end

    def popolo_url
      popolo_file.url
    end

    def group_data
      @group_data ||= memberships_at_end_of_current_term
                      .group_by(&:on_behalf_of_id)
                      .map     { |group_id, mems| [org_lookup[group_id], mems] }
                      .sort_by { |group, mems| [-mems.count, group.name] }
                      .map do    |group, mems|
        {
          group_id:     group.id.split('/').last,
          name:         group.name,
          member_count: mems.count,
        }
      end

      @group_data = [] if @group_data.length == 1
      @group_data
    end

    def people
      @people ||= house.popolo.persons.select do |p|
        wanted.include?(p.id)
      end.sort_by(&:sort_name)
    end

    def percentages
      {
        social:      ((people.count { |p| p.social.any? } / people.count.to_f) * 100).floor,
        bio:         ((people.count { |p| p.bio.any? } / people.count.to_f) * 100).floor,
        contacts:    ((people.count { |p| p.contacts.any? } / people.count.to_f) * 100).floor,
        identifiers: ((people.count { |p| p.person_identifiers(people).any? } / people.count.to_f) * 100).floor,
      }
    end

    private

    attr_reader :country_slug, :house_slug, :term_id, :index

    def popolo
      @popolo ||= EveryPolitician::Popolo.parse(popolo_file.raw)
    end

    def popolo_file
      @popolo_file ||= EveryPolitician::GithubFile.new(house[:popolo], house.sha)
    end

    def hashed_adjacent_terms
      (@prev_term, @current_term, @next_term) = adjacent_terms
      { next_term: @next_term, current_term: @current_term, prev_term: @prev_term }
    end

    def adjacent_terms
      [nil, terms, nil]
        .flatten
        .each_cons(3)
        .find { |_before, current, _after| current.slug == term_id }
    end

    def memberships_at_end_of_current_term
      @maeoct ||= current_term_memberships.select do |mem|
        mem.end_date.to_s.empty? || mem.end_date == current_term[:end_date]
      end
    end

    def wanted
      @wanted ||= Set.new(current_term_memberships.map(&:person_id))
    end

    def person_memberships(person)
      membership_lookup[person.id].map do |mem|
        membership = {
          start_date: mem.start_date,
          end_date:   mem.end_date,
        }
        membership[:group] = org_lookup[mem.on_behalf_of_id].name if mem.on_behalf_of_id
        membership[:area]  = area_lookup[mem.area_id].name if mem.area_id
        membership
      end
    end

    # Caches for faster lookup
    def membership_lookup
      @membership_lookup ||= current_term_memberships.group_by(&:person_id)
    end

    def area_lookup
      @area_lookup ||= Hash[popolo.areas.map { |a| [a.id, a] }]
    end

    def org_lookup
      @org_lookup ||= Hash[popolo.organizations.map { |org| [org.id, org] }]
    end

    def current_term_memberships
      @current_term_memberships ||= popolo.memberships.select do |mem|
        mem.legislative_period_id.split('/').last == term_id
      end
    end
  end
end
