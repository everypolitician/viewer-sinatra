# frozen_string_literal: true
class DataCompleteness
  def initialize(people:)
    @people = people
  end

  CARDS = %i(social bio contacts identifiers).freeze
  Percentages = Struct.new(*CARDS)
  def percentages
    Percentages.new(*CARDS.map { |card| calculate_completeness(card) })
  end

  private

  attr_reader :people

  def calculate_completeness(card)
    ((people.count { |p| p.send(card.to_s).any? } / people.count.to_f) * 100).floor
  end
end
