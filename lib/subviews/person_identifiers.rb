# frozen_string_literal: true
class PersonIdentifiers < PersonCard
  def entries
    person.identifiers.map do |i|
      {
        label: i[:scheme],
        value: i[:identifier],
      }
    end
  end
end
