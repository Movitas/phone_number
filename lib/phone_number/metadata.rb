require 'net/http'
require 'xmlsimple'
require 'yaml'

module PhoneNumber
  
  class Metadata
    LOCAL_XML_FILE        = File.dirname(__FILE__) + "/../../resources/PhoneNumberMetaData.xml"
    TERRITORIES_DIRECTORY = File.dirname(LOCAL_XML_FILE) + "/territories"
    
    UPSTREAM_URL = "http://libphonenumber.googlecode.com/svn/trunk/resources/PhoneNumberMetaData.xml"
    
    def self.for_region(region)
      YAML::load_file "#{TERRITORIES_DIRECTORY}/#{region}.yml" 
    end
    
    def self.download
      file = File.new LOCAL_XML_FILE, "w"
      file.write Net::HTTP.get(URI.parse(UPSTREAM_URL))
      file.close
    end
    
    def self.parse
      xml = File.read LOCAL_XML_FILE
      phone_number_meta_data = XmlSimple.xml_in xml, { 'KeyAttr' => 'id', 'ForceArray' => false }
      territories = phone_number_meta_data['territories']['territory']
      
      territories.each do |territory, data|
        file = File.new "#{TERRITORIES_DIRECTORY}/#{territory}.yml", "w"
        file.write data.to_yaml
        file.close
      end
    end
    
    private
    
    def underscore(camel_cased_word)
      word = camel_cased_word.to_s.dup
      word.gsub!(/::/, '/')
      word.gsub!(/(?:([A-Za-z\d])|^)(#{inflections.acronym_regex})(?=\b|[^a-z])/) { "#{$1}#{$1 && '_'}#{$2.downcase}" }
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end
    
  end
  
end
