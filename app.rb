require 'csv'
require 'yajl/json_gem'
require 'open-uri'
require 'sass'
require 'set'
require 'sinatra'
require 'pry'

require_relative './lib/popolo_helper'

helpers Popolo::Helper

cjson = File.read('DATASOURCE').chomp
ALL_COUNTRIES = JSON.parse(open(cjson).read, symbolize_names: true ).each do |c|
  c[:url] = c[:slug].downcase
end

wjson = File.read('world.json')
WORLD = JSON.parse(wjson, symbolize_names: true)

set :erb, trim: '-'

get '/' do
  @countries = ALL_COUNTRIES.to_a
  @world = WORLD.to_a
  erb :new_index
end

get '/countries.html' do
  @countries = ALL_COUNTRIES.to_a
  @cjson = cjson
  erb :front_index
end

get '/:country/' do |country|
  if @country = ALL_COUNTRIES.find { |c| c[:url] == country }
    erb :index
  elsif @missing = WORLD[country.to_sym]
    erb :country_missing
  else 
    halt(404)
  end
end

get '/:country/:house/term-table/:id.html' do |country, house, id|
  @country = ALL_COUNTRIES.find { |c| c[:url] == country } || halt(404)
  @house = @country[:legislatures].find { |h| h[:slug].downcase == house } || halt(404)

  last_modified Time.at(@country[:lastmod].to_i)

  @terms = @house[:legislative_periods]
  (@next_term, @term, @prev_term) = [nil, @terms, nil]
    .flatten.each_cons(3)
    .find { |_p, e, _n| e[:slug] == id }
  @page_title = @term[:name]

  last_sha = @house[:sha]
  csv_file = EveryPolitician::GithubFile.new(@term[:csv], last_sha)
  @csv = CSV.parse(csv_file.raw, headers: true, header_converters: :symbol, converters: :all)

  popolo_file = EveryPolitician::GithubFile.new(@house[:popolo], last_sha)
  popolo = JSON.parse(popolo_file.raw)

  @urls = {
    csv: csv_file.url,
    json: popolo_file.url,
  }
  @data_source = popolo.key?('meta') && popolo['meta']['source']

  erb :term_table
end

get '/about.html' do
  erb :about
end

get '/status/all_countries.html' do
  @world = WORLD.to_a
  erb :all_countries
end

get '/technical.html' do
  erb :technical
end

get '/contribute.html' do
  erb :contribute
end

get '/*.css' do |filename|
  scss :"sass/#{filename}"
end

get '/styling' do
  erb :styling
end
