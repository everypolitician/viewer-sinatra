require 'sinatra'
require 'haml'
require 'json'
require 'sass'
require_relative './lib/popolo_helper'

helpers Popolo::Helper

mapping = { 
  # filename  => [ primary, aliases (all lower case) ]
  'eduskunta' => [ 'finland', 'fi', 'eduskunta' ],
  'wales'     => [ 'wales', 'gb-wls', 'wls' ],
}

before '/:country/*' do |country, _|
  found = mapping.find { |fn, codes| codes.include? country.downcase } or 
    halt 404
  @country = found.last.first
  @popolo = Popolo::Data.new(found.first)
end


get '/' do
  @countries = mapping.map { |k, v| v.first }
  haml :front_index
end

get '/about.html' do
  haml :about
end

get '/:country/' do 
  haml :index
end

get '/:country/terms.html' do 
  @terms = @popolo.terms
  haml :terms
end

get '/:country/people.html' do 
  @people = @popolo.persons
  haml :people
end

get '/:country/parties.html' do 
  @parties = @popolo.parties
  haml :parties
end

get '/:country/term/:id' do |country, id|
  @term = @popolo.term_from_id(id) or pass
  @memberships = @popolo.term_memberships(@term)
  haml :term
end

get '/:country/person/:id' do |country, id|
  @person = @popolo.person_from_id(id) or pass
  @memberships = @popolo.person_memberships(@person)
  haml :person
end

get '/:country/party/:id' do |country, id|
  @party = @popolo.party_from_id(id) or pass
  @memberships = @popolo.party_memberships(@party['id'])
  haml :party
end

get '/styles.css' do
  scss :styles
end



