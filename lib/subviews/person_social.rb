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
      value: facebook_username,
      url:   person.facebook,
    } if person.facebook
  end

  def facebook_username
    URI.decode_www_form_component(person.facebook.split('/').last)
  end
end
