require 'sinatra'
require 'haml'
require 'json'
require_relative './lib/popolo_helper'

helpers Popolo::Helper

mapping = { 
  # filename  => [ codes ]
  'eduskunta' => [ 'fi', 'finland', 'eduskunta' ],
  'wales'     => [ 'gb-wls', 'wls', 'wales' ],
}

before '/:country/*' do |country, _|
  found = mapping.find { |fn, codes| codes.include? country.downcase } or 
    halt 404
  @pd = Popolo::Data.new(found.first)
end


get '/' do
  haml :index
end

get '/about.html' do
  haml :about
end

get '/:country/terms.html' do 
  @terms = @pd.terms
  haml :terms
end

get '/:country/people.html' do 
  @people = @pd.persons
  haml :people
end

get '/:country/parties.html' do 
  @parties = @pd.parties
  haml :parties
end

get '/:country/term/:id' do |country, id|
  @term = @pd.term_from_id(id) or pass
  @memberships = @pd.term_memberships(@term)
  haml :term
end

get '/:country/person/:id' do |country, id|
  @person = @pd.person_from_id(id) or pass
  @memberships = @pd.person_memberships(@person)
  haml :person
end

get '/:country/party/:id' do |country, id|
  @party = @pd.party_from_id(id) or pass
  @memberships = @pd.party_memberships(@party['id'])
  haml :party
end




