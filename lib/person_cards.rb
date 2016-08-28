# frozen_string_literal: true

module PersonCard
  class Base
    def initialize(person)
      @person = person
    end

    private

    attr_reader :person
  end

  class Social < Base
    def data
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
  end

  class Contacts < Base
    def data
      contacts = []
      contacts << { type: 'Email', value: person.email, link: "mailto:#{person.email}" } if person.email
      contacts << { type: 'Phone', value: person.phone } if person.phone
      contacts << { type: 'Fax', value: person.fax } if person.fax
      contacts
    end
  end

  class Bio < Base
    def data
      bio = []
      bio << { type: 'Gender', value: person.gender } if person.gender
      bio << { type: 'Born', value: person.birth_date } if person.birth_date
      bio << { type: 'Died', value: person.death_date } if person.death_date
      bio << { type: 'Prefix', value: person.honorific_prefix } if person.honorific_prefix
      bio << { type: 'Suffix', value: person.honorific_suffix } if person.honorific_suffix
      bio
    end
  end

  class Identifiers < Base
    def data(top_identifiers)
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
