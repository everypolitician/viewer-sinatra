require 'forwardable'
require 'everypolitician/popolo'

module People
  class Collection
    include Enumerable

    attr_reader :popolo
    attr_reader :person_ids

    def initialize(popolo, person_ids)
      @popolo = popolo
      @person_ids = person_ids
    end

    def popolo_people
      @popolo_people ||= popolo.persons.find_all { |p| person_ids.include?(p.id) }.sort_by { |p| p.sort_name }
    end

    def people
      @people ||= popolo_people.map do |person|
        Proxy.new(person, self)
      end
    end

    def each(&block)
      people.each(&block)
    end

    def identifiers
      @identifiers ||= popolo_people.map { |p| p.identifiers if p.respond_to?(:identifiers) }.compact.flatten
    end

    def top_identifiers
      @top_identifiers ||= identifiers.reject { |i| i[:scheme] == 'everypolitician_legacy' }
        .group_by { |i| i[:scheme] }
        .sort_by { |s, ids| -ids.size }
        .map { |s, ids| s }
        .take(3)
    end

    def memberships_by_person
      @memberships_by_person ||= popolo.memberships.group_by(&:person_id)
    end

    def areas_by_id
      @areas_by_id ||= Hash[popolo.areas.map { |a| [a.id, a] }]
    end

    def orgs_by_id
      @orgs_by_id ||= Hash[popolo.organizations.map { |o| [o.id, o] }]
    end
  end

  class Proxy
    extend Forwardable

    attr_reader :person, :collection
    def_delegators :person, :id, :name, :image

    def initialize(person, collection)
      @person = person
      @collection = collection
    end

    def memberships
      @memberships ||= collection.memberships_by_person[person.id].map do |mem|
        # FIXME: This is a bit nasty because everypolitician-popolo doesn't define
        # a on_behalf_of_id/area_id on a membership if it doesn't have one, so
        # we have to use respond_to? to check if they have that property for now.
        membership = {}
        if mem.respond_to?(:on_behalf_of_id)
          membership[:group] = collection.orgs_by_id[mem.on_behalf_of_id].name
        end
        if mem.respond_to?(:area_id)
          membership[:area] = collection.areas_by_id[mem.area_id].name
        end
        if mem.respond_to?(:start_date)
          membership[:start_date] = mem.start_date
        end
        if mem.respond_to?(:end_date)
          membership[:end_date] = mem.end_date
        end
        membership
      end
    end

    def social
      social = []
      if person.twitter
        social << { type: 'Twitter', value: "@#{person.twitter}", link: "https://twitter.com/#{person.twitter}" }
      end
      if person.facebook
        fb_username = person.facebook.split('/').last
        social << { type: 'Facebook', value: fb_username, link: "https://facebook.com/#{fb_username}" }
      end
      social
    end

    def bio
      bio = []
      if person.gender
        bio << { type: 'Gender', value: person.gender }
      end
      if person.respond_to?(:birth_date)
        bio << { type: 'Born', value: person.birth_date }
      end
      if person.respond_to?(:death_date)
        bio << { type: 'Died', value: person.death_date }
      end
      bio
    end

    def contacts
      contacts = []
      if person.email
        contacts << { type: 'Email', value: person.email, link: "mailto:#{person.email}" }
      end
      if person.respond_to?(:contact_details)
        person.contact_details.each do |cd|
          if cd[:type] == 'phone'
            contacts << { type: 'Phone', value: cd[:value] }
          end
          if cd[:type] == 'fax'
            contacts << { type: 'Fax', value: cd[:value] }
          end
        end
      end
      contacts
    end

    def identifiers
      identifiers = []
      if person.respond_to?(:identifiers)
        collection.top_identifiers.each do |scheme|
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
      end
      identifiers
    end
  end
end
