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
  @terms = Popolo::Data.new('eduskunta').terms
  haml :terms
end

get '/people.html' do
  @people = Popolo::Data.new('eduskunta').persons
  haml :people
end

get '/parties.html' do
  @parties = Popolo::Data.new('eduskunta').parties
  haml :parties
end

get '/term/:id' do |id|
  pd = Popolo::Data.new('eduskunta')
  @term = pd.term_from_id(id) or pass
  @memberships = pd.term_memberships(@term)
  haml :term
end

get '/person/:id' do |id|
  pd = Popolo::Data.new('eduskunta')
  @person = pd.person_from_id(id) or pass
  @memberships = pd.person_memberships(@person)
  haml :person
end

get '/party/:id' do |id|
  pd = Popolo::Data.new('eduskunta')
  @party = pd.party_from_id(id) or pass
  @memberships = pd.party_memberships(@party['id'])
  haml :party
end




