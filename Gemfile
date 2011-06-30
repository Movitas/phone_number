source :rubygems

group :development, :test do
  gem 'xml-simple'
  
  gem 'test-unit'
  gem 'shoulda'
  gem 'guard-test'
  
  gem 'rcov'
  
  gem 'bundler'
  gem 'jeweler'
end

require 'rbconfig'
if RbConfig::CONFIG['host_os'] =~ /darwin/i
  gem 'rb-fsevent'
  gem 'growl'
end
