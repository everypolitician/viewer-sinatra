require 'rake/testtask'
Rake::TestTask.new do |t|
  t.pattern = 't/*.rb'
end
