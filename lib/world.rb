require 'json'

class World
  def initialize(file = 'world.json')
    @file = file
  end

  def as_json
    @_wjson ||= JSON.parse(File.read(file), symbolize_names: true)
  end

  # super-simplistic adapter for the inner data. Over time it might make
  # sense to properly extract this to its own class, but for now we just
  # want to tidy the interface up a little so that this is substitutable
  # for an `everypolitician-ruby` Country in a few well-defined places.

  Country = Struct.new(:url, :name, :names)
  def country(slug)
    return unless found = as_json[slug.to_sym]
    Country.new(slug, found[:displayName], found[:allNames])
  end

  private

  attr_reader :file
end
