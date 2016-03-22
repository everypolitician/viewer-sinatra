require 'open-uri'
require 'fileutils'

module EveryPolitician

  class GithubFile

    @@GH_PATH = "https://cdn.rawgit.com/everypolitician/everypolitician-data/%s/%s"

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
          # puts "Writing #{@url} to #{@cache_file}"
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

    # http://stackoverflow.com/questions/1078347/is-there-a-rails-trick-to-adding-commas-to-large-numbers
    def commify(number)
      number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
    end

    def wikidata_link(p)
      return if p[:identifiers].nil? || p[:identifiers].empty?
      wd = p[:identifiers].find { |i| i[:scheme] == 'wikidata' } or return
      '<a href="https://www.wikidata.org/wiki/%s">%s</a>' % [ wd[:identifier], wd[:identifier] ]
    end

    def image_proxy_url(country_slug, house_slug, id)
      'https://mysociety.github.io/politician-image-proxy' \
        "/#{country_slug}/#{house_slug}/#{id}/140x140.jpeg"
    end

    def number_to_millions(num)
      (num.to_f / 1_000_000).round(1)
    end

    def featured_person(country_slug, legislature_slug, person_uuid)
      country = ALL_COUNTRIES.find { |c| c[:slug] == country_slug }
      house = country[:legislatures].find { |l| l[:slug] == legislature_slug }
      popolo = EveryPolitician::Popolo.parse(open(house[:popolo_url]).read)
      person = People::Collection.new(popolo, [person_uuid]).first
      person.define_singleton_method(:country) { country }
      person.define_singleton_method(:house) { house }
      person
    end
  end
end
