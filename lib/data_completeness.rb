# frozen_string_literal: true
# The completeness of each type of member data as a percentage
class DataCompleteness
  # @param [Array PersonCard]
  def initialize(people:)
    @people = people
  end

  CARDS = %i(social bio contacts identifiers).freeze
  Percentages = Struct.new(*CARDS)
  # The percentage of data completeness for categories defined in CARDS
  # Return [<struct DataCompleteness::Percentages>]
  def percentages
    Percentages.new(*CARDS.map { |card| calculate_completeness(card) })
  end

  private

  attr_reader :people

  def calculate_completeness(card)
    ((people.count { |p| p.send(card.to_s).any? } / people.count.to_f) * 100).floor
  end
end
