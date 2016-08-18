require 'everypolitician'
require 'json'

module Page
  class Download
    attr_reader :download_url

    def initialize(slug, index: EveryPolitician::Index.new)
      @slug = slug
      @download_url = index.index_url
      @index = index
    end

    def country
      index.country(slug)
    end

    private

    attr_reader :slug
    attr_reader :index
  end
end
