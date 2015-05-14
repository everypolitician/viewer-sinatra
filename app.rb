require 'sinatra'
require 'json'
require 'sass'
require 'csv'
require 'set'

require_relative './lib/popolo_helper'

helpers Popolo::Helper

ALL_COUNTRIES = Dir['public/data/*.json'].map { |f| 
  name = File.basename(f, '.json')
  {
    file: name,
    name: name,
    url: name.downcase,
  }
}

before '/:country/*' do |country, _|
  # Allow inbuilt sinatra requests through
  pass if country == '__sinatra__'

  @country = ALL_COUNTRIES.find { |c| c[:url] == country } or halt 404 
  @popolo = Popolo::Data.new(@country[:file])
end

set :erb, :trim => '-' 

get '/' do
  @countries = ALL_COUNTRIES.to_a
  erb :front_index
end

get '/countries.json' do
  content_type :json
  countries = ALL_COUNTRIES.map { |c|
    {
      name: c[:name],
      url: "/#{c[:url]}",
      current_term_csv: "/#{c[:url]}/term_table.csv"
    }
  }
  JSON.pretty_generate(countries)
end

get '/about.html' do
  erb :about
end

get '/:country/' do
  erb :index
end

get '/:country/terms.html' do
  @terms = @popolo.terms_with_members
  erb :terms
end

get '/:country/people.html' do
  @people = @popolo.persons
  erb :people
end

get '/:country/parties.html' do
  @parties = @popolo.parties
  #TODO make this *current* memberships
  @memberships = @popolo.legislative_memberships
  erb :parties
end

get '/:country/term/:id' do |country, id|
  @term = @popolo.term_from_id(id) or pass
  @memberships = @popolo.term_memberships(@term)
  erb :term
end

get '/:country/term_table/?:id?.html' do |country, id|
  @term = id ? @popolo.term_from_id(id) :  @popolo.current_term
  pass unless @term

  @page_title = @term['name']
  @terms = @popolo.term_list
  (@prev_term, _, @next_term) = [nil, @terms, nil].flatten.each_cons(3).find { |p, e, n| e['id'] == @term['id'] }
  @memberships = @popolo.term_memberships(@term)
  @houses = @memberships.map { |m| m['organization'] }.uniq
  @urls = {
    csv: "/#{@country[:url]}/term_table/#{@term['id'].split('/').last}.csv",
    json: "/data/#{@country[:name]}.json",
  }
  @data_source = @popolo.data_source
  erb :term_table
end

get '/:country/term_table/?:id?.csv' do |country, id|
  @term = id ? @popolo.term_from_id(id) :  @popolo.current_term
  pass unless @term

  content_type 'application/csv'
  attachment   "everypolitician-#{country}-#{@term['id'].split('/').last}.csv"
  @popolo.term_as_csv(@term)
end

get '/:country/person/:id' do |country, id|
  @person = @popolo.person_from_id(id) 
  unless @person
    people = @popolo.people_with_name(id)
    #TODO handle having more than one person with the same name
    @person = people.first or pass
  end
  @legislative_memberships = @popolo.person_legislative_memberships(@person)
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
