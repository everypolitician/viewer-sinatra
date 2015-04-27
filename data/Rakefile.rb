
@COUNTRIES = FileList['*/Rakefile.rb'].pathmap('%d')

@COUNTRIES.each do |country|
  desc "Regenerate #{country}"
  task country.to_sym do 
    Rake::Task[:regenerate].execute(country: country) 
  end
end

task :regenerate, :country do |t, args|
  country = args[:country] or abort "Need a country"
  abort "Don't know how to build #{country}" unless @COUNTRIES.include? country
  chdir country
  sh 'rake rebuild'
  chdir '..'
end

desc "Regenarate all countries"
task :regenerate_all do
  @COUNTRIES.each do |country| 
    Rake::Task[country.to_sym].execute
  end
end


