require 'sinatra'
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
  erb :front_index
end

get '/about.html' do
  erb :about
end

get '/:country/' do
  erb :index
end

get '/:country/terms.html' do
  @terms = @popolo.terms
  erb :terms
end

get '/:country/people.html' do
  @people = @popolo.persons
  erb :people
end

get '/:country/parties.html' do
  @parties = @popolo.parties
  erb :parties
end

get '/:country/term/:id' do |country, id|
  @term = @popolo.term_from_id(id) or pass
  @memberships = @popolo.term_memberships(@term)
  erb :term
end

get '/:country/person/:id' do |country, id|
  @person = @popolo.person_from_id(id) or pass
  @memberships = @popolo.person_memberships(@person)
  erb :person
end

get '/:country/party/:id' do |country, id|
  @party = @popolo.party_from_id(id) or pass
  @memberships = @popolo.party_memberships(@party['id'])
  erb :party
end

# We'll probably need a 'by-ID' version of this later, but for now most
# of the data we have only has a bare { name: X } on Memberships
get '/:country/area/:name' do |country, name|
  @area = { 'name' => name }
  @memberships = @popolo.named_area_memberships(name)
  erb :area
end


get '/*.css' do |filename|
  scss :"sass/#{filename}"
end

get '/styling' do
  erb :styling
end
