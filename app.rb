require 'sinatra'
require 'haml'
require 'json'
require_relative './lib/popolo_helper'

helpers Popolo::Helper

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
  @people = Popolo::Data.new('eduskunta').persons
  haml :people
end

get '/parties.html' do
  @parties = parties
  haml :parties
end

get '/term/:id' do |id|
  @term = term_from_id(id) or pass
  @memberships = term_memberships(@term)
  haml :term
end

get '/person/:id' do |id|
  @person = person_from_id(id) or pass
  @memberships = person_memberships(@person)
  haml :person
end

get '/party/:id' do |id|
  @party = party_from_id(id) or pass
  @memberships = party_memberships(@party['id'])
  haml :party
end




