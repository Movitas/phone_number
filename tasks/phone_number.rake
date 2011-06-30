require 'rake'
require File.dirname(__FILE__) + '/../lib/phone_number.rb'

desc "Downloads and parses country metadata from Google's libphonenumber project"
task :update do
  PhoneNumber::Metadata.download
  PhoneNumber::Metadata.parse
end

namespace :update do
  desc "Downloads XML file from Google"
  task :download do
    PhoneNumber::Metadata.download
  end
  
  desc "Parses XML into YAML files"
  task :parse do
    PhoneNumber::Metadata.parse
  end
end
