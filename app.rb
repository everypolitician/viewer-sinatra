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
  @person_count = @countries.map { |c| c[:legislatures].map { |l| l[:person_count].to_i  } }.flatten.inject(:+)
    .to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
    # http://stackoverflow.com/questions/1078347/is-there-a-rails-trick-to-adding-commas-to-large-numbers
  @world = WORLD.to_a
  erb :homepage
end

get '/countries.html' do
  @countries = ALL_COUNTRIES.to_a
  @cjson = cjson
  erb :countries
end

get '/:country/' do |country|
  if @country = ALL_COUNTRIES.find { |c| c[:url] == country }
    erb :country
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

get '/needed.html' do
  gh_url = 'https://api.github.com/repos/everypolitician/everypolitician-data/issues?labels=new%%20country,%s;per_page=100'
  @to_scrape = JSON.parse(open(gh_url % 'to%20scrape'), symbolize_names: true) rescue []
  @to_find   = JSON.parse(open(gh_url % 'to%20find'),   symbolize_names: true) rescue []
  erb :needed
end

get '/technical.html' do
  erb :technical
end

get '/contribute.html' do
  erb :contribute
end

get '/submitting.html' do
  erb :submitting
end

get '/repo_structure.html' do
  erb :repo_structure
end

get '/data_structure.html' do
  erb :data_structure
end

get '/*.css' do |filename|
  scss :"sass/#{filename}"
end

get '/styling' do
  erb :styling
end
