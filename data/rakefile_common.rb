require 'json'
require 'open-uri'
require 'rake/clean'
require 'pry'

CLEAN.include('processed.json')

Numeric.class_eval { def empty?; false; end }

file 'popit.json' do 
  popit_src = @POPIT_URL || "https://#{@POPIT || @DEST}.popit.mysociety.org/api/v0.1/export.json"
  File.write('popit.json', open(popit_src).read) 
end

task :rebuild => [ :clean, 'processed.json' ]

task :default => 'processed.json'

task :install => 'processed.json' do
  FileUtils.cp('processed.json', "../#{@DEST}.json")
end

task :load_json => 'popit.json' do
  @json = JSON.load(File.read('popit.json'), lambda { |h| 
    if h.class == Hash 
      h.reject! { |_, v| v.nil? or v.empty? }
      h.reject! { |k, v| (k == :url or k == :html_url) and v[/popit.mysociety.org/] }
    end
  }, { symbolize_names: true })
end

file 'processed.json' => :process_json do
  File.write('processed.json', JSON.pretty_generate(@json))
end  

task :clean_orphaned_memberships => :load_json do
  @json[:memberships].keep_if { |m|
    @json[:organizations].find { |o| o[:id] == m[:organization_id] } and
    @json[:persons].find { |p| p[:id] == m[:person_id] } 
  }
end  

task :ensure_legislature_exists => :load_json do
  if @json[:organizations].find_all { |h| h[:classification] == 'legislature' }.count.zero?
    @json[:organizations] << {
      classification: "legislature",
      name: "Legislature",
      id: "legislature",
    }
  end
end

task :ensure_legislative_period => :ensure_legislature_exists do
  leg = @json[:organizations].find { |h| h[:classification] == 'legislature' } or raise "No legislature"
  unless leg.has_key?(:legislative_periods) and not leg[:legislative_periods].count.zero? 
    leg[:legislative_periods] = [{
      id: 'term/current',
      name: 'current',
      classification: 'legislative period',
    }]
  end
end

task :switch_party_to_behalf => :ensure_legislature_exists do
  # TODO: Only works if *all* Orgs are Parties
  # TODO: Only works for unicameral legislature
  @json[:organizations].find_all { |h| h[:classification] != 'legislature' }.each do |o|
    @json[:memberships].find_all { |m| m[:organization_id] == o[:id] }.each do |m|
      m[:role] = 'member'
      m[:on_behalf_of_id] = o[:id]
      m[:organization_id] = 'legislature'
    end
  end
end

task :default_memberships_to_current_term => [:ensure_legislative_period] do
  @json[:memberships].find_all { |m| m[:organization_id] == 'legislature' && m[:role] == 'member' }.each do |m|
    m[:legislative_period_id] ||= 'term/current'
  end
end


