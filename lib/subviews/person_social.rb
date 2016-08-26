# frozen_string_literal: true
require_relative './person_card'
class PersonSocial < PersonCard
  def entries
    remove_entries_with_nil_values(
      [twitter, facebook]
    ).compact
  end

  private

  def twitter
    {
      label: 'Twitter',
      value: person.twitter,
      url:   twitter_url,
    }
  end

  def facebook
    {
      label: 'Facebook',
      value: facebook_username,
      url:   person.facebook,
    }
  end

  def facebook_username
    URI.decode_www_form_component(person.facebook.split('/').last)
  end

  def twitter_url
    "http://twitter.com/#{person.twitter}"
  end
end
