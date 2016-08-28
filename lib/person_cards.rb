# frozen_string_literal: true

module PersonCard
  class Base
    def initialize(person, extras={})
      @person = person
      @extras = extras
    end

    def data
      info
    end

    private

    attr_reader :person, :extras
  end

  class Social < Base
    def info
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
    def info
      contacts = []
      contacts << { type: 'Email', value: person.email, link: "mailto:#{person.email}" } if person.email
      contacts << { type: 'Phone', value: person.phone } if person.phone
      contacts << { type: 'Fax', value: person.fax } if person.fax
      contacts
    end
  end

  class Bio < Base
    def info
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
    ID_MAP = {
      wikidata: 'https://www.wikidata.org/wiki/%s',
      viaf:     'https://viaf.org/viaf/%s',
    }

    def link_for(scheme, id)
      return unless template = ID_MAP[scheme.to_sym]
      template % id
    end

    def info
      extras[:top_identifiers].select { |s| person.identifier(s) }.map do |scheme|
        id = person.identifier(scheme)
        {
          type: scheme,
          value: id,
          link: link_for(scheme, id),
        }.reject { |_, v| v.to_s.empty? }
      end
    end
  end
end
