# frozen_string_literal: true
class TermStatistics
  def initialize(term:, org_lookup:, people:)
    @term = term
    @org_lookup = org_lookup
    @people = people
  end

  def group_data
    @group_data ||= seat_counts.count == 1 ? [] : seat_counts
  end

  def members_by_group
    term
      .memberships_at_end
      .group_by(&:on_behalf_of_id)
      .map { |group_id, mems| [org_lookup[group_id].first, mems] }
  end

  def sorted_members_by_group
    members_by_group.sort_by { |group, mems| [-mems.count, group.name] }
  end

  SeatCount = Struct.new(:group_id, :name, :member_count)
  def seat_counts
    sorted_members_by_group
      .map { |group, mems| SeatCount.new(group.id.split('/').last, group.name, mems.count) }
  end

  CARDS = %i(social bio contacts identifiers).freeze
  Percentages = Struct.new(*CARDS)
  def percentages
    Percentages.new(*CARDS.map { |card| percentage_for_card(card) })
  end

  def percentage_for_card(card)
    ((people.count { |p| p.send(card.to_s).any? } / people.count.to_f) * 100).floor
  end

  private

  attr_reader :term, :org_lookup, :people
end
