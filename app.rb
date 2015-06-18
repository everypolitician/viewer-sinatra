require 'csv'
require 'yajl/json_gem'
require 'open-uri'
require 'sass'
require 'set'
require 'sinatra'

require_relative './lib/popolo_helper'

helpers Popolo::Helper

cjson = File.read('DATASOURCE').chomp
ALL_COUNTRIES = JSON.parse(open(cjson).read, symbolize_names: true ).each do |c|
  c[:name] = c[:country]
  c[:url] = File.dirname(c[:popolo]).split('/').last.downcase
end

before '/:country/*' do |country, _|
  # Allow inbuilt sinatra requests through
  pass if country == '__sinatra__'

  @country = ALL_COUNTRIES.find { |c| c[:url] == country } || halt(404)
  @popolo = Popolo::Data.new(@country)
end

set :erb, trim: '-'

get '/' do
  @countries = ALL_COUNTRIES.to_a
  erb :front_index
end

get '/countries.json' do
  content_type :json
  countries = ALL_COUNTRIES.map do |c|
    pd = Popolo::Data.new(c)
    last_term_id = pd.current_term['id'].split('/').last
    {
      name: c[:name],
      url: "/#{c[:url]}",
      code: c[:code],
      latest_term_csv: "/#{c[:url]}/term_table/#{last_term_id}.csv",
      popolo: pd.popolo_url
    }
  end
  JSON.pretty_generate(countries)
end

get '/:country/' do
  erb :index
end

get '/:country/term_table/?:id?.html' do |_country, id|
  last_modified Time.at(@popolo.lastmod.to_i)

  @term = id ? @popolo.term_from_id(id) : @popolo.current_term
  pass unless @term

  @page_title = @term['name']
  @terms = @country[:legislative_periods].sort_by { |t| t[:start_date].to_s }
  (@prev_term, _, @next_term) = [nil, @terms, nil]
                                .flatten.each_cons(3)
                                .find { |_p, e, _n| e[:id] == @term['id'] }
  @memberships = @popolo.term_memberships(@term)
  @houses = @memberships.map { |m| m['organization'] }.uniq
  @urls = {
    csv: @popolo.csv_url(@term),
    json: @popolo.popolo_url
  }
  @data_source = @popolo.data_source
  erb :term_table
end

get '/*.css' do |filename|
  scss :"sass/#{filename}"
end

get '/styling' do
  erb :styling
end
