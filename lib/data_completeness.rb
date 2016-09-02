# frozen_string_literal: true
# The completeness of each type of member data as a percentage
class DataCompleteness
  # @param [Array<PersonCard>]
  def initialize(person_cards:)
    @person_cards = person_cards
  end

  CARDS = %i(social bio contacts identifiers).freeze
  Percentages = Struct.new(*CARDS)
  # The percentage of data completeness for categories defined in CARDS
  # @return [<struct DataCompleteness::Percentages>]
  def percentages
    Percentages.new(*CARDS.map { |card| calculate_completeness(card) })
  end

  private

  attr_reader :person_cards

  def calculate_completeness(card)
    ((person_cards.count { |p| p.send(card.to_s).any? } / person_cards.count.to_f) * 100).floor
  end
end
