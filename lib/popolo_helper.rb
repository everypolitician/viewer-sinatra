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

    def image_proxy_url(id)
      'https://mysociety.github.io/politician-image-proxy' \
        "/#{@country[:slug]}/#{@house[:slug]}/#{id}/140x140.jpeg"
    end

    # Extracts the relevant bits of information for a person to be displayed
    # in a template.
    def person_for_template(person, memberships_by_person, areas_by_id, orgs_by_id)
      p = {
        id: person.id,
        name: person.name,
        image: person.image,
        proxy_image: image_proxy_url(person.id),
        memberships: memberships_by_person[person.id].map do |mem|
          # FIXME: This is a bit nasty because everypolitician-popolo doesn't define
          # a on_behalf_of_id/area_id on a membership if it doesn't have one, so
          # we have to use respond_to? to check if they have that property for now.
          membership = {}
          if mem.respond_to?(:on_behalf_of_id)
            membership[:group] = orgs_by_id[mem.on_behalf_of_id].name
          end
          if mem.respond_to?(:area_id)
            membership[:area] = areas_by_id[mem.area_id].name
          end
          if mem.respond_to?(:start_date)
            membership[:start_date] = mem.start_date
          end
          if mem.respond_to?(:end_date)
            membership[:end_date] = mem.end_date
          end
          membership
        end,
        social: [],
        bio: [],
        contacts: [],
        identifiers: []
      }

      if person.twitter
        p[:social] << { type: 'Twitter', value: "@#{person.twitter}", link: "https://twitter.com/#{person.twitter}" }
      end
      if person.facebook
        fb_username = person.facebook.split('/').last
        p[:social] << { type: 'Facebook', value: fb_username, link: "https://facebook.com/#{fb_username}" }
      end
      if person.gender
        p[:bio] << { type: 'Gender', value: person.gender }
      end
      if person.respond_to?(:birth_date)
        p[:bio] << { type: 'Born', value: person.birth_date }
      end
      if person.respond_to?(:death_date)
        p[:bio] << { type: 'Died', value: person.death_date }
      end
      if person.email
        p[:contacts] << { type: 'Email', value: person.email, link: "mailto:#{person.email}" }
      end
      if person.respond_to?(:contact_details)
        person.contact_details.each do |cd|
          if cd[:type] == 'phone'
            p[:contacts] << { type: 'Phone', value: cd[:value] }
          end
          if cd[:type] == 'fax'
            p[:contacts] << { type: 'Fax', value: cd[:value] }
          end
        end
      end
      if person.respond_to?(:identifiers)
        person.identifiers.each do |id|
          if id[:scheme] == 'wikidata'
            p[:identifiers] << { type: 'Wikidata', value: id[:identifier], link: "https://www.wikidata.org/wiki/#{id[:identifier]}" }
          end
          if id[:scheme] == 'viaf'
            p[:identifiers] << { type: 'VIAF', value: id[:identifier], link: "https://viaf.org/viaf/#{id[:identifier]}/" }
          end
        end
      end
      p
    end

    def featured_person(country_slug, legislature_slug, term_id, person_uuid)
      @country = ALL_COUNTRIES.find { |c| c[:slug] == country_slug }
      @house = @country[:legislatures].find { |l| l[:slug] == legislature_slug }
      popolo = EveryPolitician::Popolo.parse(open(@house[:popolo_url]).read)
      memberships_by_person = popolo.memberships.find_all { |m| m.legislative_period_id == "term/#{term_id}" }.group_by(&:person_id)
      areas_by_id = Hash[popolo.areas.map { |a| [a.id, a] }]
      orgs_by_id = Hash[popolo.organizations.map { |o| [o.id, o] }]
      person = popolo.persons.find { |p| p.id == person_uuid }
      person_for_template(person, memberships_by_person, areas_by_id, orgs_by_id)
    end
  end
end
