require 'sinatra'
require 'json'
require 'sass'
require 'csv'
require_relative './lib/popolo_helper'

helpers Popolo::Helper

mapping = {
  # filename  => [ primary, aliases (all lower case) ]
  'australia'     => [ 'australia', 'au' ],
  'canada'        => [ 'canada', 'ca' ],
  'denmark'       => [ 'denmark', 'dk', 'folketing' ],
  'estonia'       => [ 'estonia', 'ee', 'riigikogu' ],
  'chile'         => [ 'chile', 'cl' ],
  'finland'       => [ 'finland', 'fi', 'eduskunta' ],
  'greenland'     => [ 'greenland', 'inatsisartut', 'gl', 'grl' ],
  'iceland'       => [ 'iceland', 'is', 'alþingi', 'althing' ],
  'iran'          => [ 'iran', 'ir' ],
  'kazakhstan'    => [ 'kazakhstan', 'kz' ],
  'italy'         => [ 'italy', 'it' ],
  'wales'         => [ 'wales', 'gb-wls', 'wls' ],
}

before '/:country/*' do |country, _|
  # Allow inbuilt sinatra requests through
  pass if country == '__sinatra__'

  found = mapping.find { |fn, codes| codes.include? country.downcase } or
    halt 404
  @country = found.last.first
  @popolo = Popolo::Data.new(found.first)
end

set :erb, :trim => '-' 

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
  @country = country
  @term = id ? @popolo.term_from_id(id) :  @popolo.current_term
  pass unless @term
  @page_title = @term['name']
  @terms = @popolo.term_list
  (@prev_term, _, @next_term) = [nil, @terms, nil].flatten.each_cons(3).find { |p, e, n| e['id'] == @term['id'] }
  @memberships = @popolo.term_memberships(@term)
  @csv_url = "/#{country}/term_table/#{@term['id'].split('/').last}.csv"
  erb :term_table
end

get '/:country/term_table/?:id?.csv' do |country, id|
  @term = id ? @popolo.term_from_id(id) :  @popolo.current_term
  pass unless @term

  @terms = @popolo.term_list
  @memberships = @popolo.term_memberships(@term)

  header = %w(id name group area start_date end_date).to_csv
  rows = @memberships.sort_by { |m| [m['person']['name'], m['start_date']] }.map do |m|
    { 
      id: m['person']['id'].split('/').last,
      name: m['person']['name'],
      group: m['on_behalf_of']['name'],
      area: m['area'] && m['area']['name'],
      start_date: m['start_date'],
      end_date: m['end_date']
    }.values.to_csv
  end

  content_type 'application/csv'
  attachment   "everypolitician-#{country}-#{@term['id'].split('/').last}.csv"
  [header, rows].compact.join
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
