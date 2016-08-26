# frozen_string_literal: true
require_relative './person_card'
class PersonSocial < PersonCard
  def entries
    [twitter, facebook].compact
  end

  private

  def twitter
    {
      label: 'Twitter',
      value: person.twitter,
      url:   "http://twitter.com/#{person.twitter}",
    } if person.twitter
  end

  def facebook
    {
      label: 'Facebook',
      value: person.facebook,
      url:   person.facebook,
    } if person.facebook
  end
end
