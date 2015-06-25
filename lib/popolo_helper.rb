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
  require 'date'
  require 'yajl/json_gem'
  require 'promise'

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

    def persons
      json['persons']
    end

    def organizations
      json['organizations']
    end

    def areas
      json['areas'] || []
    end

    def memberships
      @_mems ||= json['memberships'].map do |m|
        m['organization'] ||= promise { party_from_id(m['organization_id']) }
        m['on_behalf_of'] ||= promise { party_from_id(m['on_behalf_of_id']) }
        m['person'] ||= promise { person_from_id(m['person_id']) || fail("No such person: #{m['person_id']}") }
        m['area'] ||= promise { area_from_id(m['area_id']) || fail("No such area: #{m['area_id']}") } if m['area_id']
        if m.key?('legislative_period_id')
          m['legislative_period'] ||= promise { term_from_id(m['legislative_period_id']) }
          m['start_date'] ||= promise { m['legislative_period']['start_date'] || '' }
          m['end_date'] ||= promise { m['legislative_period']['end_date'] || '' }
        end
        m
      end
    end

    def legislature
      # TODO: cope with more than one!
      json['organizations'].find { |o| o['classification'] == 'legislature' }
    end

    def chambers
      json['organizations'].find_all { |o| o['classification'] == 'chamber' }
    end

    def parties
      json['organizations'].find_all { |o| o['classification'] == 'party' }
    end

    def terms
      legislature['legislative_periods'] || legislature['terms'] || json['events'].find_all { |e| e['classification'] == 'legislative period' } 
    end

    def term_list
      terms.sort_by { |t| [(t['start_date'] || '1001-01-01'), (t['end_date'] || '2999-12-31')] }
    end

    def current_term
      term_list.last
    end

    def legislative_memberships
      memberships.find_all { |m| [legislature, chambers].flatten.map { |o| o['id'] }.include? m['organization_id'] }
    end

    def term_from_id(id)
      terms.detect { |t| t['id'] == id } || terms.detect { |t| t['id'].end_with? "/#{id}" }
    end

    def term_memberships(t)
      legislative_memberships.find_all { |m| m['legislative_period_id'] == t['id'] }
    end

    def person_from_id(id)
      persons.detect { |r| r['id'] == id } || persons.detect { |r| r['id'].end_with? "/#{id}" }
    end

    def person_memberships(p)
      memberships.find_all { |m| m['person_id'] == p['id'] }
    end

    def person_legislative_memberships(p)
      legislative_memberships.find_all { |m| m['person_id'] == p['id'] }
    end

    def party_from_id(id)
      p = organizations.detect { |r| r['id'] == id } || organizations.detect { |r| r['id'].end_with? "/#{id}" }
    end

    def party_memberships(id)
      legislative_memberships.find_all { |m| m['on_behalf_of_id'] == id }
    end

    def area_from_id(id)
      a = areas.find { |a| a['id'] == id } || areas.find { |a| a['id'].end_with? "/#{id}" }
    end

    def data_source
      json.key?('meta') && json['meta']['source']
    end

  end

  module Helper
    def term_table_url(t)
      t[:csv].sub(%r{data/([^/]+)/[^/]+/term-(.*?).csv}, '/\1/term_table/\2.html').downcase
      # t[:csv].downcase.sub(/^data/, '').sub(/term-(.*?).csv/, 'term_table/\1.html')
    end
  end
end
