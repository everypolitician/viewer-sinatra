# frozen_string_literal: true
require 'everypolitician'
require 'open-uri'
require 'fileutils'

module EveryPolitician
  module CountryExtension
    def person_count
      legislatures.map(&:person_count).inject(:+)
    end
  end

  class GithubFile
    GH_PATH = 'https://cdn.rawgit.com/everypolitician/everypolitician-data/%s/%s'

    # TODO: investigate whether we can remove this caching
    # (possibly easier to just remove this entire class)
    def initialize(file, sha, cache_dir = '_cached_data')
      @url = GH_PATH % [sha, file]

      FileUtils.mkpath cache_dir
      @cache_file = File.join cache_dir, sha + '-' + file.tr('/', '-')
    end

    attr_reader :url

    def raw
      @_data ||= begin
        File.write(@cache_file, open(@url).read) unless File.exist? @cache_file
        File.read(@cache_file)
      end
    end
  end
end

EveryPolitician::Country.include EveryPolitician::CountryExtension
