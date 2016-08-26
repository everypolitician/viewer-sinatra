# frozen_string_literal: true
class PersonContacts < PersonCard
  def entries
    [email, phone, fax].compact
  end

  private

  def email
    {
      label: 'Email',
      value: person.email,
    } if person.email
  end

  def phone
    {
      label: 'Phone',
      value: person.phone,
    } if person.phone
  end

  def fax
    {
      label: 'Fax',
      value: person.fax,
    } if person.fax
  end
end
