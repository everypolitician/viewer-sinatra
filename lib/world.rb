# frozen_string_literal: true
require 'json'

class World
  def initialize(file: 'world.json', index: nil)
    @file = file
    @index = index
  end

  def as_json
    @_wjson ||= JSON.parse(File.read(file), symbolize_names: true)
  end

  def countries
    @_countries ||= as_json.keys.map { |slug| country(slug) }.sort_by(&:name)
  end

  # super-simplistic adapter for the inner data. Over time it might make
  # sense to properly extract this to its own class, but for now we just
  # want to tidy the interface up a little so that this is substitutable
  # for an `everypolitician-ruby` Country in a few well-defined places.

  Country = Struct.new(:slug, :name, :names, :epcountry, :total_people)
  def country(slug)
    return unless found = as_json[slug.to_sym]
    ep_country = index && index.country(slug)
    Country.new(slug, found[:displayName], found[:allNames], ep_country,
                ep_country ? ep_country.person_count : 0)
  end

  private

  attr_reader :file, :index
end
