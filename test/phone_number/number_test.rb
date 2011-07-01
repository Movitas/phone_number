# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class NumberTest < Test::Unit::TestCase
  
  def setup
    @valid_number              = PhoneNumber::Number.new "+12155551212"
    @valid_number_with_plus    = PhoneNumber::Number.new "+12155551212"
    @valid_number_without_plus = PhoneNumber::Number.new "12155551212"
    @invalid_number_too_short  = PhoneNumber::Number.new "12"
    @invalid_number_too_long   = PhoneNumber::Number.new "12345678901234567890"
  end
  
  test "should require an argument" do
    assert_raise(ArgumentError) { PhoneNumber::Number.new }
  end
  
  test "should instantiate with a valid phone number" do
    assert @valid_number
  end
  
  test "should return dialed number when to_s is called" do
    assert_equal "+12155551212", @valid_number.to_s
  end
  
  test "should determine if a number is viable by length and regex" do
    assert @valid_number_with_plus   .is_viable?
    assert @valid_number_without_plus.is_viable?
    assert !@invalid_number_too_long .is_viable?
    assert !@invalid_number_too_short.is_viable?
  end
  
  test "normalize remove punctuation" do
    assert_equal "03456234", PhoneNumber::Number.new("034-56&+#234").normalize
  end
  
  test "normalize replace alpha characters" do
    assert_equal "034426486479", PhoneNumber::Number.new("034-I-am-HUNGRY").normalize
  end
  
  test "normalize non-latin digits" do
    assert_equal "255", PhoneNumber::Number.new("\uFF125\u0665").normalize
    assert_equal "520", PhoneNumber::Number.new("\u06F52\u06F0").normalize
  end
  
  test "normalize strip alpha characters" do
    assert_equal "03456234", PhoneNumber::Number.new("034-56&+a#234").normalize_digits_only
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
      assert_equal expected, PhoneNumber::Number.new(input).extract_possible_number, "<#{input}> input"
    end
  end
  
end
