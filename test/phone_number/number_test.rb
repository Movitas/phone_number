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
  
  test "should normalize dialed number" do
    dialed_number = "1800ABCDEFG"
    normalized    = "18002223334"
    number = PhoneNumber::Number.new dialed_number
    assert_equal normalized, number.normalize
    # assert_not_equal dialed_number, number.to_s
    # assert_equal normalized, number.normalize!
    # assert_equal dialed_number, number.to_s
  end
  
end
