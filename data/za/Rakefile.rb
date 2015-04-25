require_relative '../rakefile_common.rb'

@POPIT = 'za-peoples-assembly'
@DEST = 'za'


#TODO: trim Parliaments that aren't the National Assembly
task :remove_unwanted_orgs => :load_json do
  keep_type = ['Executive', 'Parliament', 'Party' ]
  keep_orgs = @json[:organizations].find_all { |o| keep_type.include? o[:classification] }.map { |o| o[:id] }
  @json[:memberships].keep_if   { |m| keep_orgs.include? m[:organization_id] }
  @json[:organizations].keep_if { |m| keep_orgs.include? m[:id] }
end

task :clean_orphaned_people => :remove_unwanted_orgs do
  keep_people = @json[:memberships].map { |m| m[:person_id] }
  @json[:persons].keep_if { |p| keep_people.include? p[:id] }
end

task :remove_interest_register => :remove_unwanted_orgs do
  @json[:persons].each { |p| p.delete :interests_register }
end

task :process_json => [:remove_unwanted_orgs, :clean_orphaned_people, :remove_interest_register]
