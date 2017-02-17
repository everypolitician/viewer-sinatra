# frozen_string_literal: true

class PersonCard
  attr_reader :positions

  def initialize(person:, term:, positions:)
    @person          = person
    @term            = term
    @positions = positions
  end

  def proxy_image
    'https://mysociety.github.io/politician-image-proxy' \
    "/#{legislature.country.slug}/#{legislature.slug}/#{id}/140x140.jpeg"
  end

  def id
    person.id
  end

  def name
    person.name
  end

  def image
    person.image
  end

  def social
    Section::Social.new(person).data
  end

  def bio
    Section::Bio.new(person).data
  end

  def contacts
    Section::Contacts.new(person).data
  end

  def identifiers
    Section::Identifiers.new(person, top_identifiers: top_identifiers).data
  end

  def memberships
    person.memberships.where(legislative_period_id: term.id)
  end

  private

  attr_reader :person, :term

  def top_identifiers
    term.top_identifiers
  end

  def legislature
    term.legislature
  end

  class Section
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
        extras[:top_identifiers].select { |s| person.identifier(s) }.take(5).map do |scheme|
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
end
