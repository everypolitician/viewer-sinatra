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

get '/:country/terms.html' do |country|
  @terms = Popolo::Data.new(country).terms
  haml :terms
end

get '/:country/people.html' do |country|
  @people = Popolo::Data.new(country).persons
  haml :people
end

get '/:country/parties.html' do |country|
  @parties = Popolo::Data.new(country).parties
  haml :parties
end

get '/:country/term/:id' do |country, id|
  pd = Popolo::Data.new(country)
  @term = pd.term_from_id(id) or pass
  @memberships = pd.term_memberships(@term)
  haml :term
end

get '/:country/person/:id' do |country, id|
  pd = Popolo::Data.new(country)
  @person = pd.person_from_id(id) or pass
  @memberships = pd.person_memberships(@person)
  haml :person
end

get '/:country/party/:id' do |country, id|
  pd = Popolo::Data.new(country)
  @party = pd.party_from_id(id) or pass
  @memberships = pd.party_memberships(@party['id'])
  haml :party
end




