module Popolo
  module Helper

    require 'date'

    def popit_data
      @_data ||= json_file('eduskunta')
    end

    def json_file(file)
      JSON.parse(File.read("data/#{file}.json"))
    end

    def persons
      popit_data['persons']
    end

    def organizations
      popit_data['organizations']
    end

    def parties
      popit_data['organizations'].find_all { |o| o['classification'] == 'party' }
    end

    def legislature
      # TODO cope with more than one!
      popit_data['organizations'].find { |o| o['classification'] == 'legislature' }
    end

    def terms
      legislature['terms']
    end

    def memberships
      popit_data['memberships']
    end

    def party_from_id(id)
      p = organizations.detect { |r| r['id'] == id } || organizations.detect { |r| r['id'].end_with? "/#{id}" }
    end

    def person_memberships(p)
      memberships.find_all { |m| m['person_id'] == p['id'] }.map { |m|
        m['organization'] ||= party_from_id(m['organization_id'])
        m['on_behalf_of'] ||= party_from_id(m['on_behalf_of_id'])
        m
      }
    end

    def legislative_memberships
      # TODO expand!
      memberships.find_all { |m| m['organization_id'] == 'legislature' }
    end

    def party_memberships(id)
      legislative_memberships.find_all { |m| m['on_behalf_of_id'] == id }.map { |m|
        m['person'] ||= person_from_id(m['person_id'])
        m
      }
    end

    def term_memberships(t)
      # for now, solely by overlapping dates
      # TODO: direct memberships
      legislative_memberships.find_all { |m| 
        ( m['start_date'] <= (t['end_date'] || Date.today.to_s) and t['start_date'] <= (m['end_date'] || Date.today.to_s) )
      }.map { |m|
        m['person'] ||= person_from_id(m['person_id'])
        m
      }
    end

    def person_from_id(id)
      persons.detect { |r| r['id'] == id } || persons.detect { |r| r['id'].end_with? "/#{id}" }
    end

    def term_from_id(id)
      terms.detect { |t| t['id'] == id } || terms.detect { |t| t['id'].end_with? "/#{id}" }
    end
  end
end

      
        
