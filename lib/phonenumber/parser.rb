require 'xmlsimple'
require 'yaml'

module PhoneNumber
  
  class Parser
    
    LOCAL_XML_FILE        = File.dirname(__FILE__) + "/../../resources/PhoneNumberMetaData.xml"
    TERRITORIES_DIRECTORY = File.dirname(LOCAL_XML_FILE) + "/territories"
    
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
    
  end
  
end
