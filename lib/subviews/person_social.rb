# frozen_string_literal: true
class PersonSocial
  def initialize(person:)
    @person = person
  end

  def view
    pat = '../../views/subviews/person_card.erb'
    content = File.read(File.expand_path(path), __FILE__)
    ERB.new(content).result(binding)
  end

  def entries
    [twitter, facebook].compact
  end

  private

  def twitter
    {
      name:  'Twitter',
      value: @person.twitter,
      url:   "http://twitter.com/#{@person.twitter}",
    } if @person.twitter
  end

  def facebook
    {
      name:  'Facebook',
      value: @person.facebook,
      url:   @person.facebook,
    } if @person.facebook
  end
end
