require 'everypolitician'
require 'json'

module Page
  class Download
    attr_reader :country, :download_url

    def initialize(country, cjson)
      # TODO: fix after everypolitician-ruby/issues/38
      @country = EveryPolitician.country(country) rescue nil
      @download_url = cjson
    end
  end
end
