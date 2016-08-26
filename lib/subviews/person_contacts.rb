# frozen_string_literal: true
class PersonContacts < PersonCard
  def entries
    remove_entries_with_nil_values(
      [email, phone, fax]
    ).compact
  end

  private

  def email
    {
      label: 'Email',
      value: person.email,
    }
  end

  def phone
    {
      label: 'Phone',
      value: person.phone,
    }
  end

  def fax
    {
      label: 'Fax',
      value: person.fax,
    }
  end
end
