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
LIVE_INDEX = EveryPolitician::Index.new(index_url: cjson)

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
  @page = Page::Home.new(index: LIVE_INDEX)
  erb :homepage
end

get '/countries.html' do
  @page = Page::Countries.new(index: LIVE_INDEX)
  erb :countries
end

get '/:country/' do |country|
  @page = Page::Country.new(country: country, index: LIVE_INDEX)
  pass unless @page.country
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
    index:   LIVE_INDEX
  )
  halt(404) unless @page.house
  erb :wikidata_match
end

get '/:country/:house/term-table/:id.html' do |country, house, termid|
  @page = Page::TermTable.new(
    country_slug: country,
    house_slug:   house,
    term_id:      termid,
    index:        EveryPolitician::Index.new(index_url: cjson)
  )
  erb :term_table
end

get '/:country/download.html' do |country|
  @page = Page::Download.new(country: country, index: LIVE_INDEX)
  # TODO: perhaps have a `valid?` method?
  halt(404) unless @page.country
  erb :country_download
end

get '/status/all_countries.html' do
  @page = Page::SpiderBase.new
  erb :all_countries
end

get '/needed.html' do
  @page = Page::Needed.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
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
