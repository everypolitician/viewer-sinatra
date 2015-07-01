require 'open-uri'
require 'fileutils'

module EveryPolitician

  class GithubFile

    @@GH_PATH = "https://raw.githubusercontent.com/everypolitician/everypolitician-data/%s/%s"

    def initialize(file, sha, cache_dir = '_cached_data')
      @url = @@GH_PATH % [sha, file]

      FileUtils.mkpath cache_dir
      @cache_file = File.join cache_dir, sha + "-" + file.tr('/', '-')
    end

    def url
      @url
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

  module Helper
    def term_table_url(c, h, t)
      "/%s/%s/term-table/%s.html" % [ c[:slug].downcase, h[:slug].downcase, t[:csv][/term-(.*?).csv/, 1] ]
    end
  end
end
