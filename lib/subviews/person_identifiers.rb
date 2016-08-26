# frozen_string_literal: true
class PersonIdentifiers < PersonCard
  def initialize(person:, identifiers:)
    @person = person
    @identifiers = identifiers
  end

  def entries
    arr = person.identifiers.map do |i|
      {
        label: i[:scheme],
        value: i[:identifier],
      } if identifiers.include? i[:scheme]
    end
    arr.compact
  end

  private

  attr_reader :identifiers
end
