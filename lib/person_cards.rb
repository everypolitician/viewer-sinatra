# frozen_string_literal: true

module PersonCard
  CardLine = Struct.new(:type, :value, :link)

  class Base
    def initialize(person, extras = {})
      @person = person
      @extras = extras
    end

    def data
      info.reject { |i| i[:value].to_s.empty? }.map do |i|
        CardLine.new(i[:type], i[:display] || i[:value], i[:link])
      end
    end

    private

    attr_reader :person, :extras
  end

  class Social < Base
    def info
      [
        { type: 'Twitter', value: person.twitter, display: "@#{person.twitter}", link: "https://twitter.com/#{person.twitter}" },
        { type: 'Facebook', value: person.facebook, display: person.facebook.to_s.split('/').last, link: person.facebook },
      ]
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
    }.freeze

    def link_for(scheme, id)
      return unless template = ID_MAP[scheme.to_sym]
      template % id
    end

    def info
      extras[:top_identifiers].select { |s| person.identifier(s) }.map do |scheme|
        id = person.identifier(scheme)
        {
          type:  scheme,
          value: id,
          link:  link_for(scheme, id),
        }
      end
    end
  end
end