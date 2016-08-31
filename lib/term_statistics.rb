# frozen_string_literal: true
class TermStatistics
  def initialize(term:, org_lookup:, people:)
    @term = term
    @org_lookup = org_lookup
    @people = people
  end

  SeatCount = Struct.new(:group_id, :name, :member_count)
  def group_data
    @group_data ||= term
                    .memberships_at_end
                    .group_by(&:on_behalf_of_id)
                    .map     { |group_id, mems| [org_lookup[group_id].first, mems] }
                    .sort_by { |group, mems| [-mems.count, group.name] }
                    .map     { |group, mems| SeatCount.new(group.id.split('/').last, group.name, mems.count) }

    @group_data = [] if @group_data.length == 1
    @group_data
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
