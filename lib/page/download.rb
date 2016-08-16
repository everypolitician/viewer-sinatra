require 'everypolitician'
require 'json'

module Page
  class Download
    attr_reader :download_url

    def initialize(slug, cjson)
      @slug = slug
      @download_url = cjson
    end

    def country
      EveryPolitician.country(slug)
    end

    private

    attr_reader :slug
  end
end
