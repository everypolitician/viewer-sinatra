require 'date'
require 'fileutils'
require 'json'
require 'open-uri'

Numeric.class_eval { def empty?; false; end }

file 'popit.json' do
  POPIT_URL = 'https://za-peoples-assembly.popit.mysociety.org/api/v0.1/export.json'
  File.write('popit.json', open(POPIT_URL).read)
end

file 'processed.json' => 'popit.json' do
  puts "PROCESSING"
  json = JSON.load(File.read('popit.json'), lambda { |h| 
    if h.class == Hash 
      h.reject! { |_, v| v.nil? or v.empty? }
      h.reject! { |k, v| (k == 'url' or k == 'html_url') and v[/popit.mysociety.org/] }
    end
  })

  keep_type = ['Executive', 'Parliament', 'Party' ]
  keep_orgs = json['organizations'].find_all { |o| keep_type.include? o['classification'] }.map { |o| o['id'] }
  json['memberships'].keep_if   { |m| keep_orgs.include? m['organization_id'] }
  json['organizations'].keep_if { |m| keep_orgs.include? m['id'] }

  keep_people = json['memberships'].map { |m| m['person_id'] }
  json['persons'].keep_if { |p| keep_people.include? p['id'] }
  json['persons'].each { |p| p.delete 'interests_register' }

  #TODO: trim Parliaments that aren't the National Assembly
  #TODO: add_on_behalf_of

  if (1 == 2) 
    leg = json['organizations'].find { |h| h['classification'] == 'legislature' }
    unless leg.has_key?('legislative_periods') and not leg['legislative_periods'].count.zero? 
      leg['legislative_periods'] = [{
        id: 'term/current',
        name: 'current',
        classification: 'legislative period',
      }]

      json['memberships'].find_all { |m| m['organization_id'] == 'legislature' && m['role'] == 'member' }.each do |m|
        m['legislative_period_id'] ||= 'term/current'
      end
    end

  end
  
  File.write('processed.json', JSON.pretty_generate(json))
end

task :clean do
  FileUtils.rm('processed.json') if File.exist?('processed.json')
end

task :rebuild => [ :clean, 'processed.json' ]

task :default => 'processed.json'

task :install => 'processed.json' do
  FileUtils.cp('processed.json', '../za.json')
end

