require 'cgi'
require 'csv'
require 'dotenv'
require 'octokit'
require 'open-uri'
require 'pry'
require 'sass'
require 'set'
require 'sinatra'
require 'yajl/json_gem'
require 'everypolitician/popolo'

require_relative './lib/popolo_helper'
require_relative './lib/people'

Dotenv.load
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
  @world = WORLD.to_a

  @world.each { |slug, country|
    cjdata = @countries.find(->{{}}) { |c| c[:url] == slug.to_s }
    country[:totalPeople] = (cjdata[:legislatures] || []).map { |l| l[:person_count].to_i }.inject(0, :+)
  }

  @total_statements = ALL_COUNTRIES.map do |c|
    c[:legislatures].map { |l| l[:statement_count] }
  end.flatten.reduce(&:+)

  @people = [
    featured_person('Belgium', 'Representatives', '54', '5f3808ae-f3e8-45da-a762-a1ffe7c8e58a'),
    featured_person('Wales', 'Assembly', '4', 'be9c1984-6f08-4a97-8ea6-e82af4daf909'),
    featured_person('Estonia', 'Riigikogu', '13', '907f006e-cf58-4fc6-a255-d92b94028dc1')
  ]

  erb :homepage
end

get '/countries.html' do
  @countries = ALL_COUNTRIES.to_a
  @world = WORLD.to_a
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

get '/:country/:house/wikidata' do |country, house|
  @country = ALL_COUNTRIES.find { |c| c[:url] == country } || halt(404)
  @house = @country[:legislatures].find { |h| h[:slug].downcase == house } || halt(404)
  last_sha = @house[:sha]
  popolo_file = EveryPolitician::GithubFile.new(@house[:popolo], last_sha)
  @popolo = JSON.parse(popolo_file.raw, symbolize_names: true)
  erb :wikidata_match
end

get '/:country/:house/term-table/:id.html' do |country, house, id|
  @country = ALL_COUNTRIES.find { |c| c[:url] == country } || halt(404)
  @house = @country[:legislatures].find { |h| h[:slug].downcase == house } || halt(404)

  @terms = @house[:legislative_periods]
  (@next_term, @term, @prev_term) = [nil, @terms, nil]
    .flatten.each_cons(3)
    .find { |_p, e, _n| e[:slug] == id }
  @page_title = @term[:name]

  last_sha = @house[:sha]
  csv_file = EveryPolitician::GithubFile.new(@term[:csv], last_sha)
  @csv = CSV.parse(csv_file.raw, headers: true, header_converters: :symbol, converters: nil)

  person_ids = @csv.map { |row| row[:id] }.uniq

  popolo_file = EveryPolitician::GithubFile.new(@house[:popolo], last_sha)
  popolo = EveryPolitician::Popolo.parse(popolo_file.raw)

  @parties = @csv.find_all { |r| r[:end_date].to_s.empty? || r[:end_date] == @term[:end_date] }
                 .group_by { |r| r[:group] }
                 .sort_by { |p, ms| [-ms.count, p] }

  @people = People::Collection.new(popolo, person_ids)

  @percentages = {
    social: ((@people.count { |p| p.social.any? } / @people.count.to_f) * 100).floor,
    bio: ((@people.count { |p| p.bio.any? } / @people.count.to_f) * 100).floor,
    contacts: ((@people.count { |p| p.contacts.any? } / @people.count.to_f) * 100).floor,
    identifiers: ((@people.count { |p| p.identifiers.any? } / @people.count.to_f) * 100).floor
  }

  @urls = {
    csv: csv_file.url,
    json: popolo_file.url,
  }

  # TODO: Make this use EveryPolitician::Popolo once that supports the 'meta' field.
  popolo_json = JSON.parse(popolo_file.raw)
  @data_sources = (popolo_json['meta']['sources'] || [popolo_json['meta']['source']]).map { |s| CGI.unescape(s) }

  erb :term_table
end

get '/status/all_countries.html' do
  @world = WORLD.to_a
  erb :all_countries
end

get '/needed.html' do
  if (token = ENV['GITHUB_ACCESS_TOKEN']).to_s.empty?
    warn "No GITHUB_ACCESS_TOKEN found"
    client = Octokit::Client.new
  else
    client = Octokit::Client.new(access_token: token)
  end
  client.auto_paginate = true

  @to_find   = client.issues 'everypolitician/everypolitician-data', labels: "New Country,To Find"
  @to_scrape = client.issues 'everypolitician/everypolitician-data', labels: "New Country,To Scrape"
  @to_finish = client.issues 'everypolitician/everypolitician-data', labels: "New Country,3 - WIP"

  erb :needed
end

get '/*.css' do |filename|
  scss :"sass/#{filename}"
end

get '/styling' do
  erb :styling
end

get '/404.html' do
  erb :fourohfour
end

not_found do
  status 404
  erb :fourohfour
end

