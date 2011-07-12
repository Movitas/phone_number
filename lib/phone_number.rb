$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'phone_number/metadata'
require 'phone_number/number'
require 'phone_number/number_util'

module PhoneNumber
  # INTERNATIONAL and NATIONAL formats are consistent with the definition in
  # ITU-T Recommendation E. 123. For example, the number of the Google Zurich
  # office will be written as '+41 44 668 1800' in INTERNATIONAL format, and as
  # '044 668 1800' in NATIONAL format. E164 format is as per INTERNATIONAL format
  # but with no formatting applied, e.g. +41446681800. RFC3966 is as per
  # INTERNATIONAL format, but with all spaces and other separating symbols
  # replaced with a hyphen, and with any phone number extension appended with
  # ';ext='.
  PHONE_NUMBER_FORMAT = {
    :E164          => 0,
    :INTERNATIONAL => 1,
    :NATIONAL      => 2,
    :RFC3966       => 3
  }.freeze
  
  # Type of phone numbers.
  PHONE_NUMBER_TYPE = {
    :FIXED_LINE => 0,
    :MOBILE => 1,
    # In some regions (e.g. the USA), it is impossible to distinguish between
    # fixed-line and mobile numbers by looking at the phone number itself.
    :FIXED_LINE_OR_MOBILE => 2,
    # Freephone lines
    :TOLL_FREE => 3,
    :PREMIUM_RATE => 4,
    # The cost of this call is shared between the caller and the recipient, and
    # is hence typically less than PREMIUM_RATE calls. See
    # http://en.wikipedia.org/wiki/Shared_Cost_Service for more information.
    :SHARED_COST => 5,
    # Voice over IP numbers. This includes TSoIP (Telephony Service over IP).
    :VOIP => 6,
    # A personal number is associated with a particular person, and may be routed
    # to either a MOBILE or FIXED_LINE number. Some more information can be found
    # here: http://en.wikipedia.org/wiki/Personal_Numbers
    :PERSONAL_NUMBER => 7,
    :PAGER => 8,
    # Used for 'Universal Access Numbers' or 'Company Numbers'. They may be
    # further routed to specific offices, but allow one number to be used for a
    # company.
    :UAN => 9,
    # A phone number is of type UNKNOWN when it does not fit any of the known
    # patterns for a specific region.
    :UNKNOWN => 10
  }.freeze
end
