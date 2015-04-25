require 'date'
require 'fileutils'
require 'json'
require 'open-uri'
require 'csv'
require 'csv_to_popolo'


# Numeric.class_eval { def empty?; false; end }

file 'popit.json' do
  POPIT_URL = 'https://australia.popit.mysociety.org/api/v0.1/export.json'
  File.write('popit.json', open(POPIT_URL).read)
end

file 'popit.csv' => 'popit.json' do
  data = JSON.load(File.read('popit.json'))['persons'].map do |p|
    { 
      id: p['ids'].find { |i| i['provider'] == 'aph_id' }['id'],
      name: p['name'],
      party: p['data']['party'][0],
      house: p['data']['house'][0],
      source: (p['links'].find { |l| l['note'] == 'aph_profile_page' } || {})['url'],
      website: (p['links'].find { |l| l['note'] == 'website' } || {})['url'],
      photo: (p['links'].find { |l| l['note'] == 'aph_profile_photo' } || {})['url'],
      email: (p['contact_details'].find { |l| l['type'] == 'email' } || {})['value'],
      facebook: (p['contact_details'].find { |l| l['type'] == 'facebook' } || {})['value'],
      twitter: (p['contact_details'].find { |l| l['type'] == 'twitter' } || {})['value'],
    }
  end
  csv = data.first.keys.to_csv  + data.map { |r| r.values.to_csv }.join
  File.write('popit.csv', csv.gsub(',null',','))
end

file 'fromcsv.json' => 'popit.csv' do
  data = Popolo::CSV.new('popit.csv').data
  json = JSON.pretty_generate(data)
  File.write('fromcsv.json', json)
end

file 'processed.json' => 'fromcsv.json' do
  json = JSON.parse(File.read('fromcsv.json'), symbolize_names: true)

  # ensure there's a legislative Organization
  if json[:organizations].find_all { |h| h[:classification] == 'legislature' }.count.zero?
    json[:organizations] << {
      classification: "legislature",
      name: "Legislature",
      id: "legislature",
    }
  end

  # ensure the chambers are children of the legislature
  json[:organizations].find_all { |h| h[:classification] == 'chamber' }.each do |c|
    c['parent_id'] ||= 'legislature'
  end

  # Add terms — Let's simply deal with Parliaments, ignoring the 6-year Senate
  # http://en.wikipedia.org/wiki/Chronology_of_Australian_federal_parliaments
  leg = json[:organizations].find { |h| h[:classification] == 'legislature' } or raise "No legislature"
  unless leg.has_key?(:legislative_periods) and not leg[:legislative_periods].count.zero? 
    leg[:legislative_periods] = [{
      id: 'term/44',
      name: '44th Parliament',
      start_date: '2013-09-07',
      classification: 'legislative period',
    }]
  end

  json[:memberships].find_all { |m| m.has_key?(:on_behalf_of_id) and m[:role] == 'member' }.each do |m|
    m[:legislative_period_id] ||= 'term/current'
  end
  

  File.write('processed.json', JSON.pretty_generate(json))
end

task :rebuild => [ :clean, 'processed.json' ]

task :clean do
  FileUtils.rm('processed.json') if File.exist?('processed.json')
end

task :default => 'processed.json'

task :install => 'processed.json' do
  FileUtils.cp('processed.json', '../australia.json')
end

