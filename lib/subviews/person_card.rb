# frozen_string_literal: true
class PersonCard
  def initialize(person:)
    @person = person
  end

  private

  attr_reader :person
end
