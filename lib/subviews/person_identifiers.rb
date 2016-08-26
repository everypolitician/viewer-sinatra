# frozen_string_literal: true
class PersonIdentifiers < PersonCard
  def initialize(person:, identifiers:)
    @person = person
    @identifiers = identifiers
  end

  def entries
    identifiers.map do |i|
      identifier = person.identifiers.find { |p| p[:scheme] == i }[:identifier]
      {
        label: i,
        value: identifier,
        url:   identifier_url(i, identifier),
      }.reject { |_k, v| v.nil? }
    end
  end

  private

  attr_reader :identifiers

  def identifier_url(type, identifier)
    {
      'wikidata': "https://www.wikidata.org/wiki/#{identifier}",
      'viaf':     "https://viaf.org/viaf/#{identifier}/",
    }[type.to_sym]
  end
end
