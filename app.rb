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

  def party_from_id(id)
    organizations.detect { |r| r['id'] == id } || organizations.detect { |r| r['id'].end_with? "/#{id}" }
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
  @parties = popit_data['organizations']
  haml :parties
end

get '/person/:id' do |id|
  @person = person_from_id(id) or pass
  haml :person
end

get '/party/:id' do |id|
  @party = party_from_id(id) or pass
  haml :party
end




