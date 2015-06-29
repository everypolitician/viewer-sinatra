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
  # Temporary workaround for new file layout, relying on only 1 house
  # TODO: cope with multiple legislatures per country
  c[:url] = c[:slug].downcase

  c[:legislatures].first.each { |k,v| c[k] ||= v }
  c.delete :legislatures

  c[:name] = c[:country]
end

before '/:country/*' do |country, _|
  # Allow inbuilt sinatra requests through
  pass if country == '__sinatra__'

  # binding.pry
  @country = ALL_COUNTRIES.find { |c| c[:url] == country } || halt(404)
  @popolo = Popolo::Data.new(@country)
end

set :erb, trim: '-'

get '/' do
  @countries = ALL_COUNTRIES.to_a
  erb :front_index
end

get '/new_index' do
  @countries = ALL_COUNTRIES.to_a
  erb :new_index, :layout => :new_layout
end

get '/:country/' do
  erb :index
end

get '/:country/term-table/:id.html' do |_, id|
  last_modified Time.at(@popolo.lastmod.to_i)

  @terms = @country[:legislative_periods]
  (@next_term, @term, @prev_term) = [nil, @terms, nil]
                                .flatten.each_cons(3)
                                .find { |_p, e, _n| e[:id].split('/').last == id }
  # Ugh
  @term['id'] = @term[:id]
  @page_title = @term[:name]
  @memberships = @popolo.term_memberships(@term)
  @houses = @memberships.map { |m| m['organization'] }.uniq
  @urls = {
    csv: @popolo.csv_url(@term),
    json: @popolo.popolo_url
  }
  @data_source = @popolo.data_source
  # @csv = CSV.parse(EveryPolitician::GithubFile.new(@urls[:csv]).raw, headers: true, header_converters: :symbol, converters: :all)
  erb :term_table
end

get '/*.css' do |filename|
  scss :"sass/#{filename}"
end

get '/styling' do
  erb :styling
end
