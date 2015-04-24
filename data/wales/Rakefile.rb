require 'date'
require 'fileutils'
require 'json'
require 'open-uri'

file 'popit.json' do
  POPIT_URL = 'https://wales.popit.mysociety.org/api/v0.1/export.json'
  File.write('popit.json', open(POPIT_URL).read)
end

task :post_process => 'popit.json' do
  json = JSON.load(File.read('popit.json'), lambda { |h| 
    if h.class == Hash 
      h.reject! { |_, v| v.nil? or v.empty? }
      h.reject! { |k, v| (k == 'url' or k == 'html_url') and v[/popit.mysociety.org/] }
    end
  })
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
  
  File.write('wales.json', JSON.pretty_generate(json))
end

task :install => :post_process do
  FileUtils.cp('wales.json', '../wales.json')
end

task :default => :post_process

