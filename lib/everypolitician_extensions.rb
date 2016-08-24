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

  module PersonExtension
    def social
      social = []
      if twitter
        social << {
          type:  'Twitter',
          value: "@#{twitter}",
          link:  "https://twitter.com/#{twitter}",
        }
      end

      if facebook
        fb_username = URI.decode_www_form_component(facebook.split('/').last)
        social << {
          type:  'Facebook',
          value: fb_username,
          link:  "https://facebook.com/#{fb_username}",
        }
      end
      social
    end

    def bio
      bio = []
      bio << { type: 'Gender', value: gender } if gender
      bio << { type: 'Born', value: birth_date } if birth_date
      bio << { type: 'Died', value: death_date } if death_date
      bio << { type: 'Prefix', value: honorific_prefix } if honorific_prefix
      bio << { type: 'Suffix', value: honorific_suffix } if honorific_suffix
      bio
    end

    def contacts
      contacts = []
      contacts << { type: 'Email', value: email, link: "mailto:#{email}" }
      contacts << { type: 'Phone', value: phone } if phone && email
      contacts << { type: 'Fax', value: fax } if fax && email
      contacts
    end

    def person_identifiers(people)
      person_identifiers = []
      if email
        top_identifiers(people).each do |scheme|
          id = identifiers.find { |i| i[:scheme] == scheme }
          next if id.nil?
          identifier = { type: id[:scheme], value: id[:identifier] }
          if identifier[:type] == 'wikidata'
            identifier[:link] = "https://www.wikidata.org/wiki/#{id[:identifier]}"
          elsif identifier[:type] == 'viaf'
            identifier[:link] = "https://viaf.org/viaf/#{id[:identifier]}/"
          end
          person_identifiers << identifier
        end
      end
      person_identifiers
    end

    private

    def top_identifiers(people)
      @tidx ||= people
                .map(&:identifiers)
                .compact
                .flatten
                .reject { |i| i[:scheme] == 'everypolitician_legacy' }
                .group_by { |i| i[:scheme] }
                .sort_by { |_s, ids| -ids.size }
                .map { |s, _ids| s }
                .take(3)
    end
  end
end

EveryPolitician::Country.include EveryPolitician::CountryExtension
EveryPolitician::Popolo::Person.include EveryPolitician::PersonExtension
