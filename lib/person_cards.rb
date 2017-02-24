# frozen_string_literal: true

# A single person card on the term table page
class PersonCard
  # @param person [Everypolitician::Popolo::Person] the person this card represents
  # @param term [Everypolitician::LegislativePeriod] the term the card is for
  def initialize(person:, term:)
    @person          = person
    @term            = term
  end

  # URL for a proxied version of the person's image
  # @return [String]
  def proxy_image
    'https://mysociety.github.io/politician-image-proxy' \
    "/#{legislature.country.slug}/#{legislature.slug}/#{id}/140x140.jpeg"
  end

  # EveryPolitician UUID for this person
  # @return [String]
  def id
    person.id
  end

  # Primary display name for this person
  # @return [String]
  def name
    person.name
  end

  # URL for the unproxied version of the person's image
  # @return [String]
  def image
    person.image
  end

  # Social media information about this person
  # @return [Array<PersonCard::Section::CardLine>]
  def social
    Section::Social.new(person).data
  end

  # Biographical information about this person
  # @return [Array<PersonCard::Section::CardLine>]
  def bio
    Section::Bio.new(person).data
  end

  # Contact details for this person
  # @return [Array<PersonCard::Section::CardLine>]
  def contacts
    Section::Contacts.new(person).data
  end

  # Identifiers for this person
  # @return [Array<PersonCard::Section::CardLine>]
  def identifiers
    Section::Identifiers.new(person, top_identifiers: top_identifiers).data
  end

  # List of cabinet memberships this person held in this term
  #
  # @example Iterating through cabinet memberships for a {PersonCard} instance.
  #   person_card.cabinet_memberships.each do |membership|
  #     puts "#{person_card.name} was #{membership.label} #{membership.start_date} - #{membership.end_date}"
  #   end
  #
  # @return [Array<Everypolitician::LegislatureExtension::CabinetMembership>]
  def cabinet_memberships
    term.cabinet_memberships.select { |membership| membership.person_id == id }
  end

  # List of legislative memberships this person held in this term
  # @return [Array<EveryPolitician::Popolo::Membership>]
  def legislative_memberships
    person.memberships.where(legislative_period_id: term.id)
  end

  alias memberships legislative_memberships

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
