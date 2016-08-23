# frozen_string_literal: true
require 'cgi'
require 'dotenv'
require 'octokit'
require 'open-uri'
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

set :erb, trim: '-'
set :docs_url, 'http://docs.everypolitician.org'
set :index, EveryPolitician::Index.new(index_url: File.read('DATASOURCE').chomp)

get '/' do
  @page = Page::Home.new(index: settings.index)
  erb :homepage
end

get '/countries.html' do
  @page = Page::Countries.new(index: settings.index)
  erb :countries
end

get '/:country/' do |slug|
  pass unless country = settings.index.country(slug)
  @page = Page::Country.new(country: country)
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
    index:   settings.index
  )
  halt(404) unless @page.house
  erb :house_wikidata
end

get '/:country/:house/term-table/:id.html' do |country, house, termid|
  @page = Page::TermTable.new(
    country_slug: country,
    house_slug:   house,
    term_id:      termid,
    index:        settings.index
  )
  erb :term_table
end

get '/:country/download.html' do |country|
  @page = Page::Download.new(country: country, index: settings.index)
  # TODO: move this (and others like it) to a pre-check instead
  halt(404) unless @page.country
  erb :country_download
end

get '/status/all_countries.html' do
  @page = Page::SpiderBase.new
  erb :spider_base
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
  docs_redirect('/', 'About')
end

set :docs_map, contribute:     'How to contribute',
               data_structure: 'About EveryPolitician’s data',
               data_summary:   'What’s in EveryPolitician’s data?',
               repo_structure: 'Getting the most recent data',
               scrapers:       'About writing scrapers',
               submitting:     'How we import data',
               technical:      'Technical overview',
               use_the_data:   'Use EveryPolitician data'

settings.docs_map.each do |page, text|
  path = '/%s.html' % page
  get path do
    docs_redirect(path, text)
  end
end

not_found do
  status 404
  erb :fourohfour
end

# Can't do server-side redirection on a GitHub Pages-hosted static site, so the
# kindest next-best-thing is to have a placeholder with meta HTTP-refresh.
# This works for humans (i.e., browsers parse and follow the redirect) but,
# because wget simply fetches the HTML document, this lets us continue to
# spider the site to generate the contents of everypolitician/viewer-static.
# See scripts/release.sh (update_viewer_static).
def docs_redirect(path, page_title)
  url = URI.join(settings.docs_url, path)
  @head_tags = [
    %(<meta http-equiv="refresh" content="0; url=#{url}">),
    %(<link rel="canonical" href="#{url}"/>),
  ].join("\n\t")
  @page_title = page_title
  erb :redirect
end
