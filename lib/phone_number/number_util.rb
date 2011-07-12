# encoding: UTF-8

module PhoneNumber
  
  class NumberUtil
    META_DATA_FILE_PREFIX = "lib/data/PhoneNumberMetadataProto"
    
    # The minimum length of the national significant number.
    MIN_LENGTH_FOR_NSN = 3
    
    # The maximum length of the national significant number.
    MAX_LENGTH_FOR_NSN = 15
    
    # The maximum length of the country calling code.
    MAX_LENGTH_COUNTRY_CODE = 3
    
    # Region-code for the unknown region.
    UNKNOWN_REGION = "ZZ"
    
    # The country code for North American Numbering Plan Administration countries
    NANPA_COUNTRY_CODE = 1
    
    # The PLUS_SIGN signifies the international prefix.
    PLUS_SIGN = '+'
    
    # The RFC 3966 format for extensions.
    RFC3966_EXTN_PREFIX = ';ext='
    
    # These mappings map a character (key) to a specific digit that should replace it for
    # normalization purposes. Non-European digits that may be used in phone numbers are
    # mapped to a European equivalent.
    DIGIT_MAPPINGS = {
      "0" => "0",
      "1" => "1",
      "2" => "2",
      "3" => "3",
      "4" => "4",
      "5" => "5",
      "6" => "6",
      "7" => "7",
      "8" => "8",
      "9" => "9",
      # Full width
      "\uFF10" => "0",
      "\uFF11" => "1",
      "\uFF12" => "2",
      "\uFF13" => "3",
      "\uFF14" => "4",
      "\uFF15" => "5",
      "\uFF16" => "6",
      "\uFF17" => "7",
      "\uFF18" => "8",
      "\uFF19" => "9",
      # Arabic-Indic
      "\u0660" => "0",
      "\u0661" => "1",
      "\u0662" => "2",
      "\u0663" => "3",
      "\u0664" => "4",
      "\u0665" => "5",
      "\u0666" => "6",
      "\u0667" => "7",
      "\u0668" => "8",
      "\u0669" => "9",
      # Extended Arabic-Indic
      "\u06F0" => "0",
      "\u06F1" => "1",
      "\u06F2" => "2",
      "\u06F3" => "3",
      "\u06F4" => "4",
      "\u06F5" => "5",
      "\u06F6" => "6",
      "\u06F7" => "7",
      "\u06F8" => "8",
      "\u06F9" => "9"
    }
    
    # Only upper-case variants of alpha characters are stored. This map is used for
    # converting letter-based numbers to their number equivalent.
    # e.g. 1-800-GOOGLE1 = 1-800-4664531
    ALPHA_MAPPINGS = {
      'A' => '2', 'B' => '2', 'C' => '2',
      'D' => '3', 'E' => '3', 'F' => '3',
      'G' => '4', 'H' => '4', 'I' => '4',
      'J' => '5', 'K' => '5', 'L' => '5',
      'M' => '6', 'N' => '6', 'O' => '6',
      'P' => '7', 'Q' => '7', 'R' => '7', 'S' => '7',
      'T' => '8', 'U' => '8', 'V' => '8',
      'W' => '9', 'X' => '9', 'Y' => '9', 'Z' => '9'
    }.freeze
    
    # For performance reasons, amalgamate both into one map
    ALL_NORMALIZATION_MAPPINGS = DIGIT_MAPPINGS.merge ALPHA_MAPPINGS
    
    # Separate map of all symbols that we wish to retain when formatting alpha
    # numbers. This includes digits, ASCII letters and number grouping symbols such
    # as '-' and ' '.
    ALL_PLUS_NUMBER_GROUPING_SYMBOLS = {
      '0' => '0',
      '1' => '1',
      '2' => '2',
      '3' => '3',
      '4' => '4',
      '5' => '5',
      '6' => '6',
      '7' => '7',
      '8' => '8',
      '9' => '9',
      'A' => 'A',
      'B' => 'B',
      'C' => 'C',
      'D' => 'D',
      'E' => 'E',
      'F' => 'F',
      'G' => 'G',
      'H' => 'H',
      'I' => 'I',
      'J' => 'J',
      'K' => 'K',
      'L' => 'L',
      'M' => 'M',
      'N' => 'N',
      'O' => 'O',
      'P' => 'P',
      'Q' => 'Q',
      'R' => 'R',
      'S' => 'S',
      'T' => 'T',
      'U' => 'U',
      'V' => 'V',
      'W' => 'W',
      'X' => 'X',
      'Y' => 'Y',
      'Z' => 'Z',
      'a' => 'A',
      'b' => 'B',
      'c' => 'C',
      'd' => 'D',
      'e' => 'E',
      'f' => 'F',
      'g' => 'G',
      'h' => 'H',
      'i' => 'I',
      'j' => 'J',
      'k' => 'K',
      'l' => 'L',
      'm' => 'M',
      'n' => 'N',
      'o' => 'O',
      'p' => 'P',
      'q' => 'Q',
      'r' => 'R',
      's' => 'S',
      't' => 'T',
      'u' => 'U',
      'v' => 'V',
      'w' => 'W',
      'x' => 'X',
      'y' => 'Y',
      'z' => 'Z',
      '-' => '-',
      '\uFF0D' => '-',
      '\u2010' => '-',
      '\u2011' => '-',
      '\u2012' => '-',
      '\u2013' => '-',
      '\u2014' => '-',
      '\u2015' => '-',
      '\u2212' => '-',
      '/'      => '/',
      '\uFF0F' => '/',
      ' '      => ' ',
      '\u3000' => ' ',
      '\u2060' => ' ',
      '.'      => '.',
      '\uFF0E' => '.'
    }.freeze
    
    # Pattern that makes it easy to distinguish whether a region has a unique
    # international dialing prefix or not. If a region has a unique international
    # prefix (e.g. 011 in USA), it will be represented as a string that contains a
    # sequence of ASCII digits. If there are multiple available international
    # prefixes in a region, they will be represented as a regex string that always
    # contains character(s) other than ASCII digits. Note this regex also includes
    # tilde, which signals waiting for the tone.
    UNIQUE_INTERNATIONAL_PREFIX = /[\d]+(?:[~\u2053\u223C\uFF5E][\d]+)?/
    # UNIQUE_INTERNATIONAL_PREFIX = Regexp.compile("[\\d]+(?:[~\u2053\u223C\uFF5E][\\d]+)?")
    
    # Regular expression of acceptable punctuation found in phone numbers. This
    # excludes punctuation found as a leading character only. This consists of dash
    # characters, white space characters, full stops, slashes, square brackets,
    # parentheses and tildes. It also includes the letter 'x' as that is found as a
    # placeholder for carrier information in some phone numbers.
    VALID_PUNCTUATION = "-x\u2010-\u2015\u2212\u30FC\uFF0D-\uFF0F \u00A0\u200B\u2060\u3000()" + "\uFF08\uFF09\uFF3B\uFF3D.\\[\\]/~\u2053\u223C\uFF5E"
    # VALID_PUNCTUATION = "-x\u2010-\u2015\u2212\uFF0D-\uFF0F " + "\u00A0\u200B\u2060\u3000()\uFF08\uFF09\uFF3B\uFF3D.\\[\\]/~\u2053\u223C\uFF5E"
    
    # Digits accepted in phone numbers (ascii, fullwidth, arabic-indic, and eastern
    # arabic digits).
    VALID_DIGITS = "0-9\uFF10-\uFF19\u0660-\u0669\u06F0-\u06F9"
    
    # We accept alpha characters in phone numbers, ASCII only, upper and lower
    # case.
    VALID_ALPHA = "A-Za-z"
    
    # Valid plus characters
    PLUS_CHARS = "+\uFF0B"
    
    #
    LEADING_PLUS_CHARS_PATTERN = Regexp.compile "^[" + PLUS_CHARS + "]+"
    
    SEPARATOR_PATTERN = Regexp.compile("[" + VALID_PUNCTUATION + "]+", "g")
    
    # Capturing digit pattern
    CAPTURING_DIGIT_PATTERN = Regexp.compile('([' + VALID_DIGITS + '])')
    
    # Regular expression of acceptable characters that may start a phone number for
    # the purposes of parsing. This allows us to strip away meaningless prefixes to
    # phone numbers that may be mistakenly given to us. This consists of digits,
    # the plus symbol and arabic-indic digits. This does not contain alpha
    # characters, although they may be used later in the number. It also does not
    # include other punctuation, as this will be stripped later during parsing and
    # is of no information value when parsing a number.
    VALID_START_CHAR_PATTERN = Regexp.compile('[' + PLUS_CHARS + VALID_DIGITS + ']')
    
    # Regular expression of characters typically used to start a second phone
    # number for the purposes of parsing. This allows us to strip off parts of the
    # number that are actually the start of another number, such as for:
    # (530) 583-6985 x302/x2303 -> the second extension here makes this actually
    # two phone numbers, (530) 583-6985 x302 and (530) 583-6985 x2303. We remove
    # the second extension so that the first number is parsed correctly.
    SECOND_NUMBER_START_PATTERN = /[\\\/] *x/
    
    # Regular expression of trailing characters that we want to remove. We remove
    # all characters that are not alpha or numerical characters. The hash character
    # is retained here, as it may signify the previous block was an extension.
    UNWANTED_END_CHAR_PATTERN = Regexp.compile('[^' + VALID_DIGITS + VALID_ALPHA + '#]+$')
    
    # We use this pattern to check if the phone number has at least three letters
    # in it - if so, then we treat it as a number where some phone-number digits
    # are represented by letters.
    VALID_ALPHA_PHONE_PATTERN = /(?:.*?[A-Za-z]){3}.*/
    # VALID_ALPHA_PHONE_PATTERN = Regexp.compile("(?:.*?[A-Za-z]){3}.*")
    
    # Regular expression of viable phone numbers. This is location independent.
    # Checks we have at least three leading digits, and only valid punctuation,
    # alpha characters and digits in the phone number. Does not include extension
    # data. The symbol 'x' is allowed here as valid punctuation since it is often
    # used as a placeholder for carrier codes, for example in Brazilian phone
    # numbers. We also allow multiple '+' characters at the start.
    # Corresponds to the following:
    # plus_sign*([punctuation]*[digits]){3,}([punctuation]|[digits]|[alpha])*
    # Note VALID_PUNCTUATION starts with a -, so must be the first in the range.
    VALID_PHONE_NUMBER = '[' + PLUS_CHARS + ']*(?:[' + VALID_PUNCTUATION + ']*[' + VALID_DIGITS + ']){3,}[' + VALID_PUNCTUATION + VALID_ALPHA + VALID_DIGITS + ']*'
    
    # Default extension prefix to use when formatting. This will be put in front of
    # any extension component of the number, after the main national number is
    # formatted. For example, if you wish the default extension formatting to be
    # ' extn: 3456', then you should specify ' extn: ' here as the default
    # extension prefix. This can be overridden by region-specific preferences.
    DEFAULT_EXTN_PREFIX = " ext. "
    
    #
    CAPTURING_EXTN_DIGITS = '([' + VALID_DIGITS + ']{1,7})'
    
    # Regexp of all possible ways to write extensions, for use when parsing. This
    # will be run as a case-insensitive regexp match. Wide character versions are
    # also provided after each ASCII version. There are three regular expressions
    # here. The first covers RFC 3966 format, where the extension is added using
    # ';ext='. The second more generic one starts with optional white space and
    # ends with an optional full stop (.), followed by zero or more spaces/tabs and
    # then the numbers themselves. The other one covers the special case of
    # American numbers where the extension is written with a hash at the end, such
    # as '- 503#'. Note that the only capturing groups should be around the digits
    # that you want to capture as part of the extension, or else parsing will fail!
    # We allow two options for representing the accented o - the character itself,
    # and one in the unicode decomposed form with the combining acute accent.
    KNOWN_EXTN_PATTERNS = RFC3966_EXTN_PREFIX + CAPTURING_EXTN_DIGITS + '|' + '[ \u00A0\\t,]*' + '(?:ext(?:ensi(?:o\u0301?|\u00F3))?n?|\uFF45\uFF58\uFF54\uFF4E?|' + '[,x\uFF58#\uFF03~\uFF5E]|int|anexo|\uFF49\uFF4E\uFF54)' + '[:\\.\uFF0E]?[ \u00A0\\t,-]*' + CAPTURING_EXTN_DIGITS + '#?|' + '[- ]+([' + VALID_DIGITS + ']{1,5})#'
    # KNOWN_EXTN_PATTERNS = "[ \u00A0\\t,]*(?:ext(?:ensio)?n?|" + "\uFF45\uFF58\uFF54\uFF4E?|[,x\uFF58#\uFF03~\uFF5E]|int|anexo|\uFF49\uFF4E\uFF54)" + "[:\\.\uFF0E]?[ \u00A0\\t,-]*([" + VALID_DIGITS + "]{1,7})#?|[- ]+([" + VALID_DIGITS + "]{1,5})#"
    
    # Regexp of all known extension prefixes used by different regions followed by
    # 1 or more valid digits, for use when parsing.
    EXTN_PATTERN = Regexp.compile('(?:' + KNOWN_EXTN_PATTERNS + ')$', 'i')
    
    # We append optionally the extension pattern to the end here, as a valid phone
    # number may have an extension prefix appended, followed by 1 or more digits.
    VALID_PHONE_NUMBER_PATTERN = Regexp.compile('^' + VALID_PHONE_NUMBER + '(?:' + KNOWN_EXTN_PATTERNS + ')?' + '$', 'i')
    
    NON_DIGITS_PATTERN = /\D+/
    # NON_DIGITS_PATTERN = Regexp.compile("(\\D+)")
    
    # This was originally set to $1 but there are some countries for which the
    # first group is not used in the national pattern (e.g. Argentina) so the $1
    # group does not match correctly.  Therefore, we use \d, so that the first
    # group actually used in the pattern will be matched.
    FIRST_GROUP_PATTERN = /(\$\d)/
    # FIRST_GROUP_PATTERN = Regexp.compile("(\\$1)")
    
    # A list of all country codes where national significant numbers (excluding any national prefix)
    # exist that start with a leading zero.
    LEADING_ZERO_COUNTRIES = [
      39,   # Italy
      47,   # Norway
      225,  # Cote d'Ivoire
      227,  # Niger
      228,  # Togo
      241,  # Gabon
      37    # Vatican City
    ].freeze
    
    NP_PATTERN = Regexp.compile("\\$NP")
    FG_PATTERN = Regexp.compile("\\$FG")
    CC_PATTERN = Regexp.compile("\\$CC")
    
    # Types of phone number matches. See detailed description beside the
    # isNumberMatch() method.
    MATCH_TYPE = {
      :NOT_A_NUMBER    => 0,
      :NO_MATCH        => 1,
      :SHORT_NSN_MATCH => 2,
      :NSN_MATCH       => 3,
      :EXACT_MATCH     => 4
    }.freeze
    
    # Possible outcomes when testing if a PhoneNumber is possible.
    VALIDATION_RESULT = {
      :IS_POSSIBLE          => 0,
      :INVALID_COUNTRY_CODE => 1,
      :TOO_SHORT            => 2,
      :TOO_LONG             => 3
    }.freeze
    
    # Attempts to extract a possible number from the string passed in. This
    # currently strips all leading characters that cannot be used to start a phone
    # number. Characters that can be used to start a phone number are defined in
    # the VALID_START_CHAR_PATTERN. If none of these characters are found in the
    # number passed in, an empty string is returned. This function also attempts to
    # strip off any alternative extensions or endings if two or more are present,
    # such as in the case of: (530) 583-6985 x302/x2303. The second extension here
    # makes this actually two phone numbers, (530) 583-6985 x302 and (530) 583-6985
    # x2303. We remove the second extension so that the first number is parsed
    # correctly
    def self.extract_possible_number(number)
      start = number.index VALID_START_CHAR_PATTERN
      
      if start
        possible_number = number[start..-1]
        # Remove trailing non-alpha non-numerical characters.
        
        possible_number = possible_number.sub UNWANTED_END_CHAR_PATTERN, ""
        
        # Check for extra numbers at the end.
        second_number_start = possible_number.index SECOND_NUMBER_START_PATTERN
        if second_number_start
          possible_number = possible_number[0..second_number_start]
        end
      else
        possible_number = "";
      end
      
      possible_number
      
    end
    
    # Checks to see if the string of characters could possibly be a phone number at all. At the
    # moment, checks to see that the string begins with at least 3 digits, ignoring any punctuation
    # commonly found in phone numbers.
    # This method does not require the number to be normalized in advance - but does assume that
    # leading non-number symbols have been removed, such as by the method extractpossible_number.
    def self.is_viable_phone_number(number)
      return false unless (MIN_LENGTH_FOR_NSN..MAX_LENGTH_FOR_NSN).include? number.length
      VALID_PHONE_NUMBER_PATTERN.match(number) ? true : false
    end
    
    # Normalizes a string of characters representing a phone number. This performs
    # the following conversions:
    #  - Wide-ascii digits are converted to normal ASCII (European) digits.
    #  - Letters are converted to their numeric representation on a telephone
    # keypad. The keypad used here is the one defined in ITU Recommendation E.161.
    # This is only done if there are 3 or more letters in the number, to lessen the
    # risk that such letters are typos - otherwise alpha characters are stripped.
    #  - Punctuation is stripped.
    #  - Arabic-Indic numerals are converted to European numerals.
    def self.normalize(number)
      if matches_entirely(VALID_ALPHA_PHONE_PATTERN, number)
        normalize_helper(number, ALL_NORMALIZATION_MAPPINGS)
      else
        normalize_helper(number, DIGIT_MAPPINGS)
      end
    end
    
    def self.normalize_digits_only(number)
      normalize_helper(number, DIGIT_MAPPINGS)
    end
    
    # Normalizes a string of characters representing a phone number by replacing
    # all characters found in the accompanying map with the values therein, and
    # stripping all other characters if removeNonMatches is true.
    def self.normalize_helper(number, normalization_replacements, remove_non_matches=true)
      normalized_number = ""
      
      number.each_char do |character|
        new_digit = normalization_replacements[character.upcase]
        
        if new_digit
          normalized_number << new_digit
        else
          normalized_number << character unless remove_non_matches
        end
        # If neither of the above are true, we remove this character.
      end
      
      normalized_number
    end
    
    # Gets the length of the geographical area code in the {@code national_number}
    # field of the PhoneNumber object passed in, so that clients could use it to
    # split a national significant number into geographical area code and
    # subscriber number. It works in such a way that the resultant subscriber
    # number should be diallable, at least on some devices. An example of how this
    # could be used:
    #
    # <pre>
    # var phoneUtil = i18n.phonenumbers.PhoneNumberUtil.getInstance();
    # var number = phoneUtil.parse('16502530000', 'US');
    # var nationalSignificantNumber =
    #     phoneUtil.getNationalSignificantNumber(number);
    # var areaCode;
    # var subscriberNumber;
    #
    # var areaCodeLength = phoneUtil.getLengthOfGeographicalAreaCode(number);
    # if (areaCodeLength > 0) {
    #   areaCode = nationalSignificantNumber.substring(0, areaCodeLength);
    #   subscriberNumber = nationalSignificantNumber.substring(areaCodeLength);
    # } else {
    #   areaCode = '';
    #   subscriberNumber = nationalSignificantNumber;
    # }
    # </pre>
    #
    # N.B.: area code is a very ambiguous concept, so the I18N team generally
    # recommends against using it for most purposes, but recommends using the more
    # general {@code national_number} instead. Read the following carefully before
    # deciding to use this method:
    # <ul>
    #  <li> geographical area codes change over time, and this method honors those
    #    changes; therefore, it doesn't guarantee the stability of the result it
    #    produces.
    #  <li> subscriber numbers may not be diallable from all devices (notably
    #    mobile devices, which typically requires the full national_number to be
    #    dialled in most regions).
    #  <li> most non-geographical numbers have no area codes.
    #  <li> some geographical numbers have no area codes.
    # </ul>
    
    # def self.get_length_of_geographical_area_code
    #     region_code = this.get_region_code_for_number(@number)
    #     return 0 unless this.is_valid_region_code(region_code)
    #     
    #     metadata = Metadata.for_region(region_code)
    #     return 0 unless metadata.has_national_prefix
    #     
    #     type = this.get_number_type_helper(this.get_national_significant_number(@number), metadata);
    #     
    #     # Most numbers other than the two types below have to be dialled in full.
    #     if type == PHONE_NUMBER_TYPE[:FIXED_LINE] or PHONE_NUMBER_TYPE[:FIXED_LINE_OR_MOBILE]
    #       this.get_length_of_national_destination_code
    #     else
    #       0
    #     end
    # 
    # end
    
    # Check whether the entire input sequence can be matched against the regular
    # expression.
    def self.matches_entirely(regex, str)
      matched_groups = (regex.class == String) ? str.match('^(?:' + regex + ')$') : str.match(regex);
      matched_length = matched_groups && matched_groups[0].length == str.length
      (matched_groups && matched_length) ? true : false
    end
    
    # Returns the region where a phone number is from. This could be used for
    # geocoding at the region level.
    # @param {i18n.phonenumbers.PhoneNumber} number the phone number whose origin
    #     we want to know.
    # @return {?string} the region where the phone number is from, or null
    #     if no region matches this calling code.
    
    # def self.get_region_code_for_number(number)
    #   country_code = Metadata.get_country_code_or_default number
    #   
    #   regions = Metadata.country_code_to_region_code_map[country_code]
    #   return nil unless regions
    #   
    #   if regions.size == 1
    #     regions.first
    #   else
    #     this.get_region_code_for_number_from_region_list(number, regions)
    #   end
    # end
    
    # Strips any extension (as in, the part of the number dialled after the call is
    # connected, usually indicated with extn, ext, x or similar) from the end of
    # the number, and returns it.
    def self.maybe_strip_extension(number)
      number_string = number.to_s
      match_start = number_string.index EXTN_PATTERN
      # If we find a potential extension, and the number preceding this is a viable
      # number, we assume it is an extension.
      
      if (match_start && match_start >= 0 && is_viable_phone_number(number_string.substring(0, match_start)))
        # The numbers are captured into groups in the regular expression.
        matched_groups = number_string.match EXTN_PATTERN
        matched_groups_length = matched_groups.length
        matched_groups.each do |group|
          if (group != nil && group.length > 0)
            # We go through the capturing groups until we find one that captured
            # some digits. If none did, then we will return the empty string.
            number.clear
            number.append(number_string.substring(0, match_start))
            return group
          end
        end
      end
      
      ""
    end
    
    
    # Checks if the number is a valid vanity (alpha) number such as 800 MICROSOFT.
    # A valid vanity number will start with at least 3 digits and will have three
    # or more alpha characters. This does not do region-specific checks - to work
    # out if this number is actually valid for a region, it should be parsed and
    # methods such as {@link #isPossibleNumberWithReason} and
    # {@link #isValidNumber} should be used.
    def self.is_alpha_number(number)
      # Number is too short, or doesn't match the basic phone number pattern.
      return false unless self.is_viable_phone_number(number)
      
      stripped_number = self.maybe_strip_extension(number)
      matches_entirely VALID_ALPHA_PHONE_PATTERN, stripped_number
    end
    
    # Formats a phone number for out-of-country dialing purposes. If no
    # regionCallingFrom is supplied, we format the number in its INTERNATIONAL
    # format. If the country calling code is the same as that of the region where
    # the number is from, then NATIONAL formatting will be applied.
    #
    # <p>If the number itself has a country calling code of zero or an otherwise
    # invalid country calling code, then we return the number with no formatting
    # applied.
    #
    # <p>Note this function takes care of the case for calling inside of NANPA and
    # between Russia and Kazakhstan (who share the same country calling code). In
    # those cases, no international prefix is used. For regions which have multiple
    # international prefixes, the number in its INTERNATIONAL format will be
    # returned instead.
    def self.format_out_of_country_calling_number(number, region_calling_from)
      if self.is_valid_region_code(region_calling_from)
        return self.format_number(number, PHONE_NUMBER_FORMAT[:INTERNATIONAL])
      end
      
      country_calling_code = number.get_country_code_or_default
      region_code = self.get_region_code_for_country_code(country_calling_code)
      national_significant_number = self.get_national_significant_number(number)
      
      if self.is_valid_region_code(region_code)
        return national_significant_number
      end
      
      if country_calling_code == NANPA_COUNTRY_CODE
        if self.is_nanpa_country(region_calling_from)
          # For NANPA regions, return the national format for these regions but
          # prefix it with the country calling code.
          return country_calling_code + " " + self.format_number(number, PHONE_NUMBER_FORMAT[:NATIONAL])
        end
      elsif country_calling_code == self.get_country_code_for_region(region_calling_from)
        # For regions that share a country calling code, the country calling code
        # need not be dialled. This also applies when dialling within a region, so
        # this if clause covers both these cases. Technically this is the case for
        # dialling from La Reunion to other overseas departments of France (French
        # Guiana, Martinique, Guadeloupe), but not vice versa - so we don't cover
        # this edge case for now and for those cases return the version including
        # country calling code. Details here:
        # http://www.petitfute.com/voyage/225-info-pratiques-reunion
        return self.format_number(number, PHONE_NUMBER_FORMAT[:NATIONAL])
      end
      
      formatted_national_number = self.format_national_number(national_significant_number, region_code, PHONE_NUMBER_FORMAT[:INTERNATIONAL])
      metadata = self.get_metadata_for_region(region_calling_from)
      international_prefix = metadata.get_international_prefix_or_default
      formatted_extension = self.maybe_get_formatted_extension(number, region_code, PHONE_NUMBER_FORMAT[:INTERNATIONAL])

      # For regions that have multiple international prefixes, the international
      # format of the number is returned, unless there is a preferred international
      # prefix.
      international_prefix_for_formatting = ""
      
      if self.matches_entirely(UNIQUE_INTERNATIONAL_PREFIX, international_prefix)
        international_prefix_for_formatting = international_prefix
      elsif metadata.has_preferred_international_prefix
        international_prefix_for_formatting = metadata.get_preffered_international_prefix_or_default
      end
      
      return international_prefix_for_formatting.nonzero? ? international_prefix_for_formatting + " " + country_calling_code + " " + formatted_national_number + formatted_extension : this.format_number_by_format(country_calling_code, PHONE_NUMBER_FORMAT[:INTERNATIONAL], formatted_national_number, formatted_extension)
    end
    
    # Gets the national significant number of the a phone number. Note a national
    # significant number doesn't contain a national prefix or any formatting.
    def self.get_national_significant_number(number)
      # The leading zero in the national (significant) number of an Italian phone
      # number has a special meaning. Unlike the rest of the world, it indicates
      # the number is a landline number. There have been plans to migrate landline
      # numbers to start with the digit two since December 2000, but it has not yet
      # happened. See http://en.wikipedia.org/wiki/%2B39 for more details. Other
      # regions such as Cote d'Ivoire and Gabon use this for their mobile numbers.
      national_number = "#{number.national_number}"
      
      if number.italian_leading_zero && self.is_leading_zero_possible(number.country_code)
        return "0" + national_number
      end
    end
    
    # Formats a phone number in the specified format using default rules. Note that
    # this does not promise to produce a phone number that the user can dial from
    # where they are - although we do format in either 'national' or
    # 'international' format depending on what the client asks for, we do not
    # currently support a more abbreviated format, such as for users in the same
    # 'area' who could potentially dial the number without area code. Note that if
    # the phone number has a country calling code of 0 or an otherwise invalid
    # country calling code, we cannot work out which formatting rules to apply so
    # we return the national significant number with no formatting applied.
    def self.format_number(number, number_format)
      country_calling_code = number.country_code
      national_significant_number = self.get_national_significant_number(number)
      if number_format == PHONE_NUMBER_FORMAT[:E164]
        # Early exit for E164 case since no formatting of the national number needs
        # to be applied. Extensions are not formatted.
        return self.format_number_by_format(country_calling_code, PHONE_NUMBER_FORMAT[:E164], national_significant_number, "")
      end
      
      # Note getRegionCodeForCountryCode() is used because formatting information
      # for regions which share a country calling code is contained by only one
      # region for performance reasons. For example, for NANPA regions it will be
      # contained in the metadata for US.
      region_code = self.get_region_code_for_country_code(country_calling_code)
      unless self.is_valid_region_code(region_code)
        return national_significant_number
      end
      
      formatted_extension = self.maybe_get_formatted_extension(number, region_code, number_format)
      formatted_national_number = self.format_national_number(national_significant_number, region_code, number_format)
      self.format_number_by_format(country_calling_code, number_format, formatted_national_number, formatted_extension)
    end
    
    # Note in some regions, the national number can be written in two completely
    # different ways depending on whether it forms part of the NATIONAL format or
    # INTERNATIONAL format. The numberFormat parameter here is used to specify
    # which format to use for those cases. If a carrierCode is specified, this will
    # be inserted into the formatted string to replace $CC.
    def format_national_number(number, region_code, number_format, opt_carrier_code)
      metadata = Metadata.for_region(region_code)
      international_number_formats = metadata['intlNumberFormat']
      # When the intlNumberFormats exists, we use that to format national number
      # for the INTERNATIONAL format instead of using the numberDesc.numberFormats.
      
      available_formats = (international_number_formats.length == 0 or numberFormat PHONE_NUMBER_FORMAT[:NATIONAL]) ? metadata.number_formats : metadata.international_number_formats
      formatted_national_number = this.format_according_to_formats(number, available_formats, number_format, opt_carrier_code)
      if number_format == PHONE_NUMBER_FORMAT[:RFC3966]
        formatted_national_number = formatted_national_number.replace(SEPARATOR_PATTERN, '-')
      end
      return
    end
    
    # Gets the formatted extension of a phone number, if the phone number had an
    # extension specified. If not, it returns an empty string.
    def self.maybe_get_formatted_extension(number, region_code, number_format)
      if !number.extension or number.extension().length == 0
        return ""
      else
        if number_format == PHONE_NUMBER_FORMAT[:RFC3966]
          return RFC3966_EXTN_PREFIX + number.extension
        end
        
        return this.format_extension(number.extension, region_code)
      end
    end
    
    # Formats the extension part of the phone number by prefixing it with the
    # appropriate extension prefix. This will be the default extension prefix,
    # unless overridden by a preferred extension prefix for this region.
    def format_extension(extension_digits, region_code)
      metadata = Metadata.for_region(region_code)
      
      if metadata['preferredExtensionPrefix']
        return metadata['preferredExtensionPrefix'] + extension_digits
      else
        return DEFAULT_EXTN_PREFIX + extension_digits
      end
    end
    
    # Helper function to check region code is not unknown or null.
    def self.is_valid_region_code(region_code)
      region_code && Metadata.for_region(region_code.upcase)
    end
    
    # Returns the region code that matches the specific country calling code. In
    # the case of no region code being found, ZZ will be returned. In the case of
    # multiple regions, the one designated in the metadata as the 'main' region for
    # this calling code will be returned.
    def self.get_region_code_for_country_code(country_calling_code)
      region_codes = Metadata.country_code_to_region[country_calling_code]
      region_codes ? region_codes.first : UNKNOWN_REGION
    end
    
  end
  
end