module PhoneNumber
  
  class Number
    
    COUNTRY_CODE_SOURCE = {
      :FROM_NUMBER_WITH_PLUS_SIGN => 1,
      :FROM_NUMBER_WITH_IDD => 5,
      :FROM_NUMBER_WITHOUT_PLUS_SIGN => 10,
      :FROM_DEFAULT_COUNTRY => 20
    }.freeze
    
    attr_accessor :number, :country_code, :national_number, :extension, :italian_leading_zero, :raw_input, :country_code_source, :preferred_domestic_carrier_code
    
    alias_method :to_s, :number
    
    def initialize(number, options=nil)
      @number = number
      
      if options
        @country_code = options[:country_code]
      end
    end
    
  end
  
end
