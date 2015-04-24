module Popolo

  require 'date'
  require 'json'
  require 'promise'

  class Data

    def initialize(file)
      @_file = file
    end

    def json
      @_data ||= JSON.parse(File.read("data/#{@_file}.json"))
    end

    def persons
      json['persons']
    end

    def organizations
      json['organizations']
    end

    def memberships
      @_mems ||= json['memberships'].map { |m|
        m['organization'] ||= promise { party_from_id(m['organization_id']) }
        m['on_behalf_of'] ||= promise { party_from_id(m['on_behalf_of_id']) }
        m['person']       ||= promise { person_from_id(m['person_id'])      }
        if m.has_key?('legislative_period_id')
          m['legislative_period'] ||= promise { term_from_id(m['legislative_period_id']) }
          m['start_date'] ||= promise { m['legislative_period']['start_date'] || '' }
          m['end_date'] ||= promise { m['legislative_period']['end_date'] || '' }
        end
        m
      }
    end

    def legislature
      # TODO cope with more than one!
      json['organizations'].find { |o| o['classification'] == 'legislature' }
    end

    def parties
      json['organizations'].find_all { |o| o['classification'] == 'party' }
    end

    def terms
      legislature['legislative_periods'] || legislature['terms'] 
    end

    def terms_with_members
      terms.reject { |t| term_memberships(t).count.zero? }
    end

    # This will need to become a lot fancier, but it'll do for now
    def current_term
      terms.find { |t| not t.has_key? 'end_date' }
    end

    def legislative_memberships
      memberships.find_all { |m| m['organization_id'] == 'legislature' }
    end


    def term_from_id(id)
      terms.detect { |t| t['id'] == id } || terms.detect { |t| t['id'].end_with? "/#{id}" }
    end

    def term_memberships(t)
      mems_with_terms = legislative_memberships.find_all { |m| m.has_key? 'legislative_period_id' }

      if mems_with_terms.count.zero?
        # for now, solely by overlapping dates
        return legislative_memberships.find_all { |m| 
          ( m['start_date'] <= (t['end_date'] || Date.today.to_s) and t['start_date'] <= (m['end_date'] || Date.today.to_s) )
        }
      else
        return mems_with_terms.find_all { |m| m['legislative_period_id'] == t['id'] }
      end
    end

    def person_from_id(id)
      persons.detect { |r| r['id'] == id } || persons.detect { |r| r['id'].end_with? "/#{id}" }
    end

    def people_with_name(name)
      persons.find_all { |p| p['name'] == name } 
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

    def named_area_memberships(name)
      legislative_memberships.find_all { |m| m.has_key?('area') && m['area']['name'] == name }
    end

  end

  module Helper

    def generate_url(type, obj)
      raise "#{type} is Nil" if obj.nil?
      raise "#{type} has no 'id': #{obj}" unless obj.has_key? 'id'
      [ '', @country, type, obj['id'].split('/').last ].join("/")
    end

    def person_url(p)
      generate_url('person', p)
    end

    def party_url(p)
      generate_url('party', p)
    end

    def term_url(t)
      generate_url('term', t)
    end

    def area_name_url(t)
      # Ugh. We should probably change generate_url to take an
      # (optional) argument for which key to look up by
      generate_url('area', {'id' => t})
    end

  end
end

