# frozen_string_literal: true

module PersonCard
  class Base
    def initialize(person, extras={})
      @person = person
      @extras = extras
    end

    def data
      info.reject { |i| i[:value].to_s.empty? }
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
      [
        { type: 'Email', value: person.email, link: "mailto:#{person.email}" },
        { type: 'Phone', value: person.phone },
        { type: 'Fax', value: person.fax },
      ]
    end
  end

  class Bio < Base
    def info
      [
        { type: 'Gender', value: person.gender },
        { type: 'Born', value: person.birth_date },
        { type: 'Died', value: person.death_date },
        { type: 'Prefix', value: person.honorific_prefix },
        { type: 'Suffix', value: person.honorific_suffix },
      ]
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
