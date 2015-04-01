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

  def memberships
    popit_data['memberships']
  end

  def party_from_id(id)
    p = organizations.detect { |r| r['id'] == id } || organizations.detect { |r| r['id'].end_with? "/#{id}" }
  end

  def party_memberships(id)
    memberships.find_all { |m| m['on_behalf_of_id'] == id }.map { |m|
      m['person'] ||= person_from_id(m['person_id'])
      m
    }
  end

  def person_from_id(id)
    persons.detect { |r| r['id'] == id } || persons.detect { |r| r['id'].end_with? "/#{id}" }
  end

end

get '/' do
  haml :index
end

get '/about.html' do
  haml :about
end

get '/people.html' do
  @people = persons
  haml :people
end

get '/parties.html' do
  @parties = parties
  haml :parties
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




