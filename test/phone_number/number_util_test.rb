# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class NumberUtilTest < Test::Unit::TestCase
  
  # Set up some test numbers to re-use.
  ALPHA_NUMERIC_NUMBER = PhoneNumber::NumberUtil.new "80074935247", :country_code => "1"
  AR_MOBILE = PhoneNumber::NumberUtil.new "91187654321", :country_code => "54"
  AR_NUMBER = PhoneNumber::NumberUtil.new "1187654321", :country_code => "54"
  AU_NUMBER = PhoneNumber::NumberUtil.new "236618300", :country_code => "61"
  BS_MOBILE = PhoneNumber::NumberUtil.new "2423570000", :country_code => "1"
  BS_NUMBER = PhoneNumber::NumberUtil.new "2423651234", :country_code => "1"
  
  # Note that this is the same as the example number for DE in the metadata.
  DE_NUMBER = PhoneNumber::Number.new "30123456", :country_code => "49"
  DE_SHORT_NUMBER = PhoneNumber::Number.new "1234", :country_code => "49"
  GB_MOBILE = PhoneNumber::Number.new "7912345678", :country_code => "44"
  GB_NUMBER = PhoneNumber::Number.new "2070313000", :country_code => "44"
  IT_MOBILE = PhoneNumber::Number.new "345678901", :country_code => "39"
  IT_NUMBER = PhoneNumber::Number.new "236618300", :country_code => "39", :italian_leading_zero => true
  
  # Numbers to test the formatting rules from Mexico.
  MX_MOBILE1 = PhoneNumber::Number.new "12345678900", :country_code => "52"
  MX_MOBILE2 = PhoneNumber::Number.new "15512345678", :country_code => "52"
  MX_NUMBER1 = PhoneNumber::Number.new "3312345678", :country_code => "52"
  MX_NUMBER2 = PhoneNumber::Number.new "8211234567", :country_code => "52"
  NZ_NUMBER = PhoneNumber::Number.new "33316005", :country_code => "64"
  SG_NUMBER = PhoneNumber::Number.new "65218000", :country_code => "65"
  
  # A too-long and hence invalid US number.
  US_LONG_NUMBER = PhoneNumber::Number.new "65025300001", :country_code => "1"
  US_NUMBER = PhoneNumber::Number.new "6502530000", :country_code => "1"
  US_PREMIUM = PhoneNumber::Number.new "9002530000", :country_code => "1"
  
  # Too short, but still possible US numbers.
  US_LOCAL_NUMBER = PhoneNumber::Number.new "2530000", :country_code => "1"
  US_SHORT_BY_ONE_NUMBER = PhoneNumber::Number.new "650253000", :country_code => "1"
  US_TOLLFREE = PhoneNumber::Number.new "8002530000", :country_code => "1"
  
  test "should require an argument" do
    assert_raise(ArgumentError) { PhoneNumber::Number.new }
  end
  
  test "should instantiate with a valid phone number" do
    assert PhoneNumber::Number.new "+12155551212"
  end
  
  test "should instantiate with a country_code option" do
    pn = PhoneNumber::Number.new "2155551212", :country_code => "1"
    assert pn
    assert_equal "2155551212", pn.number
    assert_equal "1", pn.country_code
    # assert_equal "+12155551212", number.to_s
  end
  
  test "is viable phone number" do
    # Only one or two digits before strange non-possible punctuation.
    assert !PhoneNumber::NumberUtil.is_viable_phone_number("12. March")
    assert !PhoneNumber::NumberUtil.is_viable_phone_number("1+1+1")
    assert !PhoneNumber::NumberUtil.is_viable_phone_number("80+0")
    assert !PhoneNumber::NumberUtil.is_viable_phone_number("00")
    
    # Three digits is viable.
    assert PhoneNumber::NumberUtil.is_viable_phone_number("111")
    
    # Alpha numbers.
    assert PhoneNumber::NumberUtil.is_viable_phone_number("0800-4-pizza")
    assert PhoneNumber::NumberUtil.is_viable_phone_number("0800-4-PIZZA")
  end

  test "is_viable_phone_numberPhoneNumberNonAscii" do
    # Only one or two digits before possible punctuation followed by more digits.
    assert PhoneNumber::NumberUtil.is_viable_phone_number("1\u300034")
    assert !PhoneNumber::NumberUtil.is_viable_phone_number("1\u30003+4")
    
    # Unicode variants of possible starting character and other allowed
    # punctuation/digits.
    assert PhoneNumber::NumberUtil.is_viable_phone_number("\uFF081\uFF09\u30003456789")
    
    # Testing a leading + is okay.
    assert PhoneNumber::NumberUtil.is_viable_phone_number("+1\uFF09\u30003456789")
  end
  
  test "normalize remove punctuation" do
    assert_equal "03456234", PhoneNumber::NumberUtil.normalize("034-56&+#234")
  end
  
  test "normalize replace alpha characters" do
    assert_equal "034426486479", PhoneNumber::NumberUtil.normalize("034-I-am-HUNGRY")
  end
  
  test "normalize non-latin digits" do
    assert_equal "255", PhoneNumber::NumberUtil.normalize("\uFF125\u0665")
    assert_equal "520", PhoneNumber::NumberUtil.normalize("\u06F52\u06F0")
  end
  
  test "normalize strip alpha characters" do
    assert_equal "03456234", PhoneNumber::NumberUtil.normalize_digits_only("034-56&+a#234")
  end
  
  test "extract possible number" do
    assertions = {
      # Removes preceding funky punctuation and letters but leaves the rest
      # untouched.
      "0800-345-600" => "Tel:0800-345-600",
      "0800 FOR PIZZA" => "Tel:0800 FOR PIZZA",
      # Should not remove plus sign
      "+800-345-600" => "Tel:+800-345-600",
      # Should recognise wide digits as possible start values.
      "\uFF10\uFF12\uFF13" => "\uFF10\uFF12\uFF13",
      # Dashes are not possible start values and should be removed.
      "\uFF11\uFF12\uFF13" => "Num-\uFF11\uFF12\uFF13",
      # If not possible number present, return empty string.
      "" => "Num-....",
      # Leading brackets are stripped - these are not used when parsing.
      "650) 253-0000" => "(650) 253-0000",
      # Trailing non-alpha-numeric characters should be removed.
      "650) 253-0000" => "(650) 253-0000..- ..",
      "650) 253-0000" => "(650) 253-0000.",
      # This case has a trailing RTL char.
      "650) 253-0000" => "(650) 253-0000\u200F"
    }
    
    assertions.each do |expected, input|
      assert_equal expected, PhoneNumber::NumberUtil.extract_possible_number(input), "<#{input}> input"
    end
  end
  
  # test "is alpha number" do
  #   assert PhoneNumber::NumberUtil.is_alpha_number("1800 six-flags"), "<\"1800 six-flags\"> input"
  #   assert PhoneNumber::NumberUtil.is_alpha_number("1800 six-flags ext. 1234"), "\"<1800 six-flags ext. 1234\"> input"
  #   assert !PhoneNumber::NumberUtil.is_alpha_number("1800 123-1234"), "<\"1800 123-1234\"> input"
  #   assert !PhoneNumber::NumberUtil.is_alpha_number("1800 123-1234 extension: 1234"), "<\"1800 123-1234 extension: 1234\"> input"
  # end
  
  test "format out of country calling number" do
    assert_equal "00 1 900 253 0000", PhoneNumber::NumberUtil.format_out_of_country_calling_number(US_PREMIUM, "DE")
    assert_equal "1 650 253 0000", PhoneNumber::NumberUtil.format_out_of_country_calling_number(US_NUMBER, "BS")
    assert_equal "0~0 1 650 253 0000", PhoneNumber::NumberUtil.format_out_of_country_calling_number(US_NUMBER, "PL")
    assert_equal "011 44 7912 345 678", PhoneNumber::NumberUtil.format_out_of_country_calling_number(GB_MOBILE, "US")
    assert_equal "00 49 1234", PhoneNumber::NumberUtil.format_out_of_country_calling_number(DE_SHORT_NUMBER, "GB")
    
    # Note this number is correctly formatted without national prefix. Most of
    # the numbers that are treated as invalid numbers by the library are short
    # numbers, and they are usually not dialed with national prefix.
    assert_equal "1234", PhoneNumber::NumberUtil.format_out_of_country_calling_number(DE_SHORT_NUMBER, "DE")
    assert_equal "011 39 02 3661 8300", PhoneNumber::NumberUtil.format_out_of_country_calling_number(IT_NUMBER, "US")
    assert_equal "02 3661 8300", PhoneNumber::NumberUtil.format_out_of_country_calling_number(IT_NUMBER, "IT")
    assert_equal "+39 02 3661 8300", PhoneNumber::NumberUtil.format_out_of_country_calling_number(IT_NUMBER, "SG")
    assert_equal "6521 8000", PhoneNumber::NumberUtil.format_out_of_country_calling_number(SG_NUMBER, "SG")
    assert_equal "011 54 9 11 8765 4321", PhoneNumber::NumberUtil.format_out_of_country_calling_number(AR_MOBILE, "US")
    
    # var arNumberWithExtn = AR_MOBILE.clone();
    # arNumberWithExtn.setExtension('1234');
    # assertEquals('011 54 9 11 8765 4321 ext. 1234', phoneUtil.formatOutOfCountryCallingNumber(arNumberWithExtn, RegionCode.US));
    # assertEquals('0011 54 9 11 8765 4321 ext. 1234', phoneUtil.formatOutOfCountryCallingNumber(arNumberWithExtn, RegionCode.AU));
    # assertEquals('011 15 8765-4321 ext. 1234'
  end
  
end
