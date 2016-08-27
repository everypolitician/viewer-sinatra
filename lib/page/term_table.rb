# frozen_string_literal: true
require 'everypolitician'
require_relative '../everypolitician_extensions'

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
      @group_data ||= term
                      .memberships_at_end
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
      @people ||= people_for_current_term.sort_by(&:sort_name).map do |person|
        p = {
          id:          person.id,
          name:        person.name,
          image:       person.image,
          proxy_image: image_proxy_url(person.id),
          memberships: person_memberships(person),
          social:      social_card(person),
          bio:         bio_card(person),
          contacts:    contacts_card(person),
          identifiers: identifiers_card(person),
        }

        p
      end
    end

    def percentages
      {
        social:      ((people.count { |p| p[:social].any? } / people.count.to_f) * 100).floor,
        bio:         ((people.count { |p| p[:bio].any? } / people.count.to_f) * 100).floor,
        contacts:    ((people.count { |p| p[:contacts].any? } / people.count.to_f) * 100).floor,
        identifiers: ((people.count { |p| p[:identifiers].any? } / people.count.to_f) * 100).floor,
      }
    end

    private

    attr_reader :term

    def popolo
      @popolo ||= house.popolo
    end

    def wanted
      @wanted ||= Set.new(current_term_memberships.map(&:person_id))
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

    def image_proxy_url(id)
      'https://mysociety.github.io/politician-image-proxy' \
      "/#{country.slug}/#{house.slug}/#{id}/140x140.jpeg"
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
      @ctm ||= term.memberships
    end

    def people_for_current_term
      @pct ||= popolo.persons.select { |p| wanted.include?(p.id) }
    end

    # Cards for display. WIP: will be factored out elsewhere

    def social_card(person)
      social_data = []

      if person.twitter
        social_data << { type: 'Twitter', value: "@#{person.twitter}", link: "https://twitter.com/#{person.twitter}" }
      end

      if person.facebook
        fb_username = URI.decode_www_form_component(person.facebook.split('/').last)
        social_data << { type: 'Facebook', value: fb_username, link: "https://facebook.com/#{fb_username}" }
      end

      social_data
    end

    def bio_card(person)
      bio = []
      bio << { type: 'Gender', value: person.gender } if person.gender
      bio << { type: 'Born', value: person.birth_date } if person.birth_date
      bio << { type: 'Died', value: person.death_date } if person.death_date
      bio << { type: 'Prefix', value: person.honorific_prefix } if person.honorific_prefix
      bio << { type: 'Suffix', value: person.honorific_suffix } if person.honorific_suffix
      bio
    end

    def contacts_card(person)
      contacts = []
      contacts << { type: 'Email', value: person.email, link: "mailto:#{person.email}" } if person.email
      contacts << { type: 'Phone', value: person.phone } if person.phone
      contacts << { type: 'Fax', value: person.fax } if person.fax
      contacts
    end

    def identifiers_card(person)
      identifiers = []
      top_identifiers.each do |scheme|
        id = person.identifiers.find { |i| i[:scheme] == scheme }
        next if id.nil?
        identifier = { type: id[:scheme], value: id[:identifier] }
        if identifier[:type] == 'wikidata'
          identifier[:link] = "https://www.wikidata.org/wiki/#{id[:identifier]}"
        elsif identifier[:type] == 'viaf'
          identifier[:link] = "https://viaf.org/viaf/#{id[:identifier]}/"
        end
        identifiers << identifier
      end
      identifiers
    end
  end
end
