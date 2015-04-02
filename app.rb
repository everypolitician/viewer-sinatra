require 'sinatra'
require 'haml'
require 'json'

helpers do

  def popit_data
    @_data ||= json_file('popit')
  end

  def json_file(file)
    JSON.parse(File.read("data/#{file}.json"))
  end

  def persons
    popit_data['persons']
  end

  def organizations
    popit_data['organizations']
  end

  def parties
    popit_data['organizations'].find_all { |o| o['classification'] == 'party' }
  end

  def legislature
    # TODO cope with more than one!
    popit_data['organizations'].find { |o| o['classification'] == 'legislature' }
  end

  def terms
    legislature['terms']
  end

  def memberships
    popit_data['memberships']
  end

  def party_from_id(id)
    p = organizations.detect { |r| r['id'] == id } || organizations.detect { |r| r['id'].end_with? "/#{id}" }
  end

  def legislative_memberships
    # TODO expand!
    memberships.find_all { |m| m['organization_id'] == 'legislature' }
  end

  def party_memberships(id)
    legislative_memberships.find_all { |m| m['on_behalf_of_id'] == id }.map { |m|
      m['person'] ||= person_from_id(m['person_id'])
      m
    }
  end

  def person_from_id(id)
    persons.detect { |r| r['id'] == id } || persons.detect { |r| r['id'].end_with? "/#{id}" }
  end

  def term_from_id(id)
    terms.detect { |t| t['id'] == id } || terms.detect { |t| t['id'].end_with? "/#{id}" }
  end

end

get '/' do
  haml :index
end

get '/about.html' do
  haml :about
end

get '/terms.html' do
  @terms = terms
  haml :terms
end

get '/people.html' do
  @people = persons
  haml :people
end

get '/parties.html' do
  @parties = parties
  haml :parties
end

get '/term/:id' do |id|
  @term = term_from_id(id) or pass
  haml :term
end

get '/person/:id' do |id|
  @person = person_from_id(id) or pass
  haml :person
end

get '/party/:id' do |id|
  @party = party_from_id(id) or pass
  @memberships = party_memberships(@party['id'])
  haml :party
end




