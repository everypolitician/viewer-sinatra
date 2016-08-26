# frozen_string_literal: true
require_relative './person_card'
class PersonBio < PersonCard
  def entries
    remove_entries_with_nil_values(
      [
        gender, birth_date,
        death_date,
        honorific_prefix,
        honorific_suffix,
      ]
    ).compact
  end

  private

  def gender
    { label: 'Gender',
      value: person.gender, }
  end

  def birth_date
    { label: 'Born',
      value: person.birth_date, }
  end

  def death_date
    { label: 'Died',
      value: person.death_date, }
  end

  def honorific_prefix
    { label: 'Prefix',
      value: person.honorific_prefix, }
  end

  def honorific_suffix
    { label: 'Suffix',
      value: person.honorific_suffix, }
  end
end
