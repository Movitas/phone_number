require 'rake'
require 'lib/phonenumber'

desc "Downloads and parses country metadata from Google's libphonenumber project"
task :update do
  PhoneNumber::Parser.download
  PhoneNumber::Parser.parse
end

namespace :update do
  desc "Downloads XML file from Google"
  task :download do
    PhoneNumber::Parser.download
  end
  
  desc "Parses XML into YAML files"
  task :parse do
    PhoneNumber::Parser.parse
  end
end