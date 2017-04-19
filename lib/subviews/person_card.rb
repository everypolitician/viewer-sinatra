# frozen_string_literal: true
class PersonCard
  def initialize(person:)
    @person = person
  end

  private

  attr_reader :person

  def remove_entries_with_nil_values(arr)
    arr.reject do |i|
      i.value? nil
    end
  end
end
