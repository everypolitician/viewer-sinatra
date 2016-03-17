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
  people = popolo.persons.find_all { |p| person_ids.include?(p.id) }.sort_by { |p| p.sort_name }

  @parties = @csv.find_all { |r| r[:end_date].to_s.empty? || r[:end_date] == @term[:end_date] }
                 .group_by { |r| r[:group] }
                 .sort_by { |p, ms| [-ms.count, p] }

  memberships_by_person = popolo.memberships.find_all { |m| m.legislative_period_id == "term/#{id}" }.group_by(&:person_id)
  areas_by_id = Hash[popolo.areas.map { |a| [a.id, a] }]
  orgs_by_id = Hash[popolo.organizations.map { |o| [o.id, o] }]

  identifiers = people.map { |p| p.identifiers if p.respond_to?(:identifiers) }.compact.flatten
  top_identifiers = identifiers.reject { |i| i[:scheme] == 'everypolitician_legacy' }
                               .group_by { |i| i[:scheme] }
                               .sort_by { |s, ids| -ids.size }
                               .map { |s, ids| s }
                               .take(3)

  @people = people.map do |person|
    p = {
      id: person.id,
      name: person.name,
      image: person.image,
      proxy_image: image_proxy_url(person.id),
      memberships: memberships_by_person[person.id].map do |mem|
        # FIXME: This is a bit nasty because everypolitician-popolo doesn't define
        # a on_behalf_of_id/area_id on a membership if it doesn't have one, so
        # we have to use respond_to? to check if they have that property for now.
        membership = {}
        if mem.respond_to?(:on_behalf_of_id)
          membership[:group] = orgs_by_id[mem.on_behalf_of_id].name
        end
        if mem.respond_to?(:area_id)
          membership[:area] = areas_by_id[mem.area_id].name
        end
        if mem.respond_to?(:start_date)
          membership[:start_date] = mem.start_date
        end
        if mem.respond_to?(:end_date)
          membership[:end_date] = mem.end_date
        end
        membership
      end,
      social: [],
      bio: [],
      contacts: [],
      identifiers: []
    }

    if person.twitter
      p[:social] << { type: 'Twitter', value: "@#{person.twitter}", link: "https://twitter.com/#{person.twitter}" }
    end
    if person.facebook
      fb_username = person.facebook.split('/').last
      p[:social] << { type: 'Facebook', value: fb_username, link: "https://facebook.com/#{fb_username}" }
    end
    if person.gender
      p[:bio] << { type: 'Gender', value: person.gender }
    end
    if person.respond_to?(:birth_date)
      p[:bio] << { type: 'Born', value: person.birth_date }
    end
    if person.respond_to?(:death_date)
      p[:bio] << { type: 'Died', value: person.death_date }
    end
    if person.email
      p[:contacts] << { type: 'Email', value: person.email, link: "mailto:#{person.email}" }
    end
    if person.respond_to?(:contact_details)
      person.contact_details.each do |cd|
        if cd[:type] == 'phone'
          p[:contacts] << { type: 'Phone', value: cd[:value] }
        end
        if cd[:type] == 'fax'
          p[:contacts] << { type: 'Fax', value: cd[:value] }
        end
      end
    end
    if person.respond_to?(:identifiers)
      top_identifiers.each do |scheme|
        id = person.identifiers.find { |i| i[:scheme] == scheme }
        next if id.nil?
        identifier = { type: id[:scheme], value: id[:identifier] }
        if identifier[:type] == 'wikidata'
          identifier[:link] = "https://www.wikidata.org/wiki/#{id[:identifier]}"
        elsif identifier[:type] == 'viaf'
          identifier[:link] = "https://viaf.org/viaf/#{id[:identifier]}/"
        end
        p[:identifiers] << identifier
      end
    end
    p
  end

  @percentages = {
    social: ((@people.count { |p| p[:social].any? } / @people.count.to_f) * 100).floor,
    bio: ((@people.count { |p| p[:bio].any? } / @people.count.to_f) * 100).floor,
    contacts: ((@people.count { |p| p[:contacts].any? } / @people.count.to_f) * 100).floor,
    identifiers: ((@people.count { |p| p[:identifiers].any? } / @people.count.to_f) * 100).floor
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

