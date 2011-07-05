# encoding: UTF-8

require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class MetadataTest < Test::Unit::TestCase
  
  def setup
    @metadata = PhoneNumber::Metadata
  end
  
  test "load US metadata" do
    metadata = @metadata.for_region "US"
    assert_equal "1",   metadata['countryCode']
    assert_equal "011", metadata['internationalPrefix']
    assert_equal "1",   metadata['nationalPrefix']
    assert_equal 2,     metadata['availableFormats']['numberFormat'].size
    # assertEquals('(\\d{3})(\\d{3})(\\d{4})', metadata.getNumberFormat(0).getPattern());
    # assertEquals('$1 $2 $3', metadata.getNumberFormat(0).getFormat());
    # assertEquals('[13-9]\\d{9}|2[0-35-9]\\d{8}', metadata.getGeneralDesc().getNationalNumberPattern());
    # assertEquals('\\d{7}(?:\\d{3})?', metadata.getGeneralDesc().getPossibleNumberPattern());
    # assertTrue(metadata.getGeneralDesc().equals(metadata.getFixedLine()));
    # assertEquals('\\d{10}', metadata.getTollFree().getPossibleNumberPattern());
    # assertEquals('900\\d{7}', metadata.getPremiumRate().getNationalNumberPattern());
    # # No shared-cost data is available, so it should be initialised to 'NA'.
    # assertEquals('NA', metadata.getSharedCost().getNationalNumberPattern());
    # assertEquals('NA', metadata.getSharedCost().getPossibleNumberPattern());
  end
  
  test "load MX metadata" do
    metadata = @metadata.for_region "MX"
    assert_equal "52",    metadata['countryCode']
    assert_equal "0[09]", metadata['internationalPrefix']
    assert_equal "01",    metadata['nationalPrefix']
    assert_equal 4,       metadata['availableFormats']['numberFormat'].size
  end
  
end
