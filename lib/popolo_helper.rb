require 'open-uri'
require 'fileutils'

module EveryPolitician

  class GithubFile

    def initialize(url, cache_dir = '_cached_data')
      FileUtils.mkpath cache_dir
      @cache_file = File.join cache_dir, url.split('/everypolitician-data/').last.tr('/', '-')
      @url = url
    end

    def raw
      @_data ||= begin
        unless File.exist? @cache_file
          puts "Writing #{@url} to #{@cache_file}"
          File.write @cache_file, open(@url).read
        end
        File.read(@cache_file)
      end
    end
  end
end

module Popolo
  require 'yajl/json_gem'

  class Data
    def initialize(c, cache_dir = '_cached_data')
      FileUtils.mkpath cache_dir

      @lastmod = c[:lastmod]

      @github_url = "https://raw.githubusercontent.com/everypolitician/everypolitician-data/#{c[:sha]}/"
      @popolo_url = @github_url + c[:popolo]
      @term_list  = c[:legislative_periods]
    end

    def json
      @_data ||= JSON.parse( EveryPolitician::GithubFile.new(@popolo_url).raw )
    end

    def lastmod
      @lastmod 
    end

    def popolo_url
      @popolo_url
    end

    def csv_url(term)
      found = @term_list.find { |t| t[:id].split('/').last == term['id'].split('/').last } or return
      @github_url + found[:csv]
    end

    def data_source
      json.key?('meta') && json['meta']['source']
    end

  end

  module Helper
    def term_table_url(t)
      # TODO include the _correct_ legislature when we handle >1
      "/%s/%s/term-table/%s.html" % [ @country[:slug].downcase, @country[:legislatures].first[:slug].downcase, t[:csv][/term-(.*?).csv/, 1] ]
    end
  end
end
