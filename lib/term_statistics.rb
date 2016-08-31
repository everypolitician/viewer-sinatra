# frozen_string_literal: true
class TermStatistics
  def initialize(term:, org_lookup:)
    @term = term
    @org_lookup = org_lookup
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

  private

  attr_reader :term, :org_lookup
end
