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
      url:   twitter_url,
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

  def twitter_url
    "http://twitter.com/#{person.twitter}"
  end
end
