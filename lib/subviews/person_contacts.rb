# frozen_string_literal: true
class PersonContacts < PersonCard
  def entries
    email = contact_info type: 'email', label: 'Email'
    phone = contact_info type: 'phone', label: 'Phone'
    fax = contact_info type: 'fax', label: 'Fax'
    remove_entries_with_nil_values([email, phone, fax].flatten)
  end

  private

  def contact_info(type:, label:)
    person.contact_details
          .select { |i| i[:type] == type }
          .map { |i| { label: label, value: i[:value] } }
  end
end
