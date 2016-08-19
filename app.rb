# frozen_string_literal: true
require 'cgi'
require 'dotenv'
require 'octokit'
require 'open-uri'
require 'pry'
require 'require_all'
require 'sass'
require 'set'
require 'sinatra'
require 'yajl/json_gem'
require 'everypolitician'
require 'everypolitician/popolo'

require_relative './lib/popolo_helper'
require_rel './lib/page'

Dotenv.load
helpers Popolo::Helper

cjson = File.read('DATASOURCE').chomp
EveryPolitician.countries_json = cjson

ALL_COUNTRIES = JSON.parse(open(cjson).read, symbolize_names: true).each do |c|
  c[:url] = c[:slug].downcase
end

wjson = File.read('world.json')
WORLD = JSON.parse(wjson, symbolize_names: true)

DOCS_URL = 'http://docs.everypolitician.org'

# Can't do server-side redirection on a GitHub Pages-hosted static site, so the
# kindest next-best-thing is to have a placeholder with meta HTTP-refresh.
# This works for humans (i.e., browsers parse and follow the redirect) but,
# because wget simply fetches the HTML document, this lets us continue to
# spider the site to generate the contents of everypolitician/viewer-static.
# See scripts/release.sh (update_viewer_static).
def soft_redirect(url, page_title)
  @head_tags = [
    %(<meta http-equiv="refresh" content="0; url=#{url}">),
    %(<link rel="canonical" href="#{url}"/>),
  ].join("\n\t")
  @page_title = page_title
  erb :redirect
end

set :erb, trim: '-'

get '/' do
  @page = Page::Home.new(index: EveryPolitician::Index.new(index_url: cjson))
  erb :homepage
end

get '/countries.html' do
  @countries = ALL_COUNTRIES.to_a
  @world = WORLD.to_a
  @cjson = cjson
  erb :countries
end

get '/:country/' do |country|
  @country = ALL_COUNTRIES.find { |c| c[:url] == country } || pass
  @page_title = "EveryPolitician: #{@country[:name]}"
  erb :country
end

get '/:country/' do |country|
  @page = Page::MissingCountry.new(country: country)
  pass unless @page.country
  erb :country_missing
end

get '/:country/:house/wikidata' do |country, house|
  @page = Page::HouseWikidata.new(
    country: country,
    house:   house,
    index:   EveryPolitician::Index.new(index_url: cjson)
  )
  halt(404) unless @page.house
  erb :wikidata_match
end

get '/:country/:house/term-table/:id.html' do |country, house, termid|
  @country = ALL_COUNTRIES.find { |c| c[:url] == country } || halt(404)
  @house = @country[:legislatures].find { |h| h[:slug].downcase == house } || halt(404)

  @terms = @house[:legislative_periods]
  (@next_term, @term, @prev_term) = [nil, @terms, nil]
                                    .flatten.each_cons(3)
                                    .find { |_p, e, _n| e[:slug] == termid }
  @page_title = "EveryPolitician: #{@country[:name]} — #{@house[:name]} - #{@term[:name]}"

  last_sha = @house[:sha]

  popolo_file = EveryPolitician::GithubFile.new(@house[:popolo], last_sha)
  popolo = EveryPolitician::Popolo.parse(popolo_file.raw)

  # We only want memberships that are in the requested term.
  term_memberships = popolo.memberships.select { |m| m.legislative_period_id.split('/').last == termid }

  # Pull all the people who held a membership in this term out of the Popolo.
  wanted_people = Set.new(term_memberships.map(&:person_id))
  people = popolo.persons.select { |p| wanted_people.include?(p.id) }

  # Create a few hashes so that looking up memberships and their related orgs and areas is faster.
  membership_lookup = term_memberships.group_by(&:person_id)
  area_lookup = Hash[popolo.areas.map { |a| [a.id, a] }]
  org_lookup  = Hash[popolo.organizations.map { |o| [o.id, o] }]

  # Groups, ordered by size, with name and count of how many members
  # they had at the end of the term. Don't include this section if
  # there is only a single group.
  @group_data = term_memberships.select { |mem| mem.end_date.to_s.empty? || mem.end_date == @term[:end_date] }
                                .group_by(&:on_behalf_of_id)
                                .map { |group_id, mems| [org_lookup[group_id], mems] }
                                .sort_by { |group, mems| [-mems.count, group.name] }
                                .map { |group, mems| { group_id: group.id.split('/').last, name: group.name, member_count: mems.count } }
  @group_data = [] if @group_data.length == 1

  identifiers = people.map(&:identifiers).compact.flatten
  top_identifiers = identifiers.reject { |i| i[:scheme] == 'everypolitician_legacy' }
                               .group_by { |i| i[:scheme] }
                               .sort_by { |_s, ids| -ids.size }
                               .map { |s, _ids| s }
                               .take(3)

  @people = people.sort_by(&:sort_name).map do |person|
    p = {
      id:          person.id,
      name:        person.name,
      image:       person.image,
      proxy_image: image_proxy_url(person.id),
      memberships: membership_lookup[person.id].map do |mem|
        membership = {
          start_date: mem.start_date,
          end_date:   mem.end_date,
        }
        membership[:group] = org_lookup[mem.on_behalf_of_id].name if mem.on_behalf_of_id
        membership[:area] = area_lookup[mem.area_id].name if mem.area_id
        membership
      end,
      social:      [],
      bio:         [],
      contacts:    [],
      identifiers: [],
    }

    if person.twitter
      p[:social] << { type: 'Twitter', value: "@#{person.twitter}", link: "https://twitter.com/#{person.twitter}" }
    end
    if person.facebook
      fb_username = URI.decode_www_form_component(person.facebook.split('/').last)
      p[:social] << { type: 'Facebook', value: fb_username, link: "https://facebook.com/#{fb_username}" }
    end
    p[:bio] << { type: 'Gender', value: person.gender } if person.gender
    p[:bio] << { type: 'Born', value: person.birth_date } if person.birth_date
    p[:bio] << { type: 'Died', value: person.death_date } if person.death_date
    p[:bio] << { type: 'Prefix', value: person.honorific_prefix } if person.honorific_prefix
    p[:bio] << { type: 'Suffix', value: person.honorific_suffix } if person.honorific_suffix
    p[:contacts] << { type: 'Email', value: person.email, link: "mailto:#{person.email}" } if person.email
    p[:contacts] << { type: 'Phone', value: person.phone } if person.phone
    p[:contacts] << { type: 'Fax', value: person.fax } if person.fax
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
    p
  end

  @percentages = {
    social:      ((@people.count { |p| p[:social].any? } / @people.count.to_f) * 100).floor,
    bio:         ((@people.count { |p| p[:bio].any? } / @people.count.to_f) * 100).floor,
    contacts:    ((@people.count { |p| p[:contacts].any? } / @people.count.to_f) * 100).floor,
    identifiers: ((@people.count { |p| p[:identifiers].any? } / @people.count.to_f) * 100).floor,
  }

  @urls = {
    csv:  @term[:csv_url],
    json: popolo_file.url,
  }

  @data_sources = popolo.popolo[:meta][:sources].map { |s| CGI.unescape(s) }

  erb :term_table
end

get '/:country/download.html' do |country|
  @page = Page::Download.new(
    country: country,
    index:   EveryPolitician::Index.new(index_url: cjson)
  )
  # TODO: perhaps have a `valid?` method?
  halt(404) unless @page.country
  erb :country_download
end

get '/status/all_countries.html' do
  @page = Page::SpiderBase.new
  erb :all_countries
end

get '/needed.html' do
  if (token = ENV['GITHUB_ACCESS_TOKEN']).to_s.empty?
    warn 'No GITHUB_ACCESS_TOKEN found'
    client = Octokit::Client.new
  else
    client = Octokit::Client.new(access_token: token)
  end
  client.auto_paginate = true

  @to_find   = client.issues 'everypolitician/everypolitician-data', labels: 'New Country,To Find'
  @to_scrape = client.issues 'everypolitician/everypolitician-data', labels: 'New Country,To Scrape'
  @to_finish = client.issues 'everypolitician/everypolitician-data', labels: 'New Country,3 - WIP'

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

# Old doc pages are now at docs.everypolitician.org: redirect to them
get '/about.html' do
  # note: about.html -> docs subdomain root (/)
  soft_redirect(DOCS_URL + '/', 'About')
end

get '/contribute.html' do
  soft_redirect(DOCS_URL + request.path_info, 'How to contribute')
end

get '/data_structure.html' do
  soft_redirect(DOCS_URL + request.path_info, 'About EveryPolitician’s data')
end

get '/data_summary.html' do
  soft_redirect(DOCS_URL + request.path_info, 'What’s in EveryPolitician’s data?')
end

get '/repo_structure.html' do
  soft_redirect(DOCS_URL + request.path_info, 'Getting the most recent data')
end

get '/scrapers.html' do
  soft_redirect(DOCS_URL + request.path_info, 'About writing scrapers')
end

get '/submitting.html' do
  soft_redirect(DOCS_URL + request.path_info, 'How we import data')
end

get '/technical.html' do
  soft_redirect(DOCS_URL + request.path_info, 'Technical overview')
end

get '/use_the_data.html' do
  soft_redirect(DOCS_URL + request.path_info, 'Use EveryPolitician data')
end

not_found do
  status 404
  erb :fourohfour
end
