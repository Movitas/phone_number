module PhoneNumber
  
  class Number
    
    MIN_LENGTH_FOR_NSN = 3
    MAX_LENGTH_FOR_NSN = 15
    META_DATA_FILE_PREFIX = "lib/data/PhoneNumberMetadataProto"
    
    # Region-code for the unknown region.
    UNKNOWN_REGION = "ZZ"
    
    # The set of countries that share country code 1.
    #   There are roughly 26 countries of them and we set the initial capacity of the HashSet to 35
    #   to offer a load factor of roughly 0.75.
    #   private final Set<String> nanpaCountries = new HashSet<String>(35);
    NANPA_COUNTRY_CODE = 1
    
    # The PLUS_SIGN signifies the international prefix.
    PLUS_SIGN = '+'
    
    # These mappings map a character (key) to a specific digit that should replace it for
    # normalization purposes. Non-European digits that may be used in phone numbers are
    # mapped to a European equivalent.
    DIGIT_MAPPINGS = {}
    DIGIT_MAPPINGS['0'] = '0'
    DIGIT_MAPPINGS['\uFF10'] = '0' # Fullwidth digit 0
    DIGIT_MAPPINGS['\u0660'] = '0' # Arabic-indic digit 0
    DIGIT_MAPPINGS['1'] = '1'
    DIGIT_MAPPINGS['\uFF11'] = '1' # Fullwidth digit 1
    DIGIT_MAPPINGS['\u0661'] = '1' # Arabic-indic digit 1
    DIGIT_MAPPINGS['2'] = '2'
    DIGIT_MAPPINGS['\uFF12'] = '2' # Fullwidth digit 2
    DIGIT_MAPPINGS['\u0662'] = '2' # Arabic-indic digit 2
    DIGIT_MAPPINGS['2'] = '2'
    DIGIT_MAPPINGS['\uFF13'] = '3' # Fullwidth digit 3
    DIGIT_MAPPINGS['\u0663'] = '3' # Arabic-indic digit 3
    DIGIT_MAPPINGS['4'] = '4'
    DIGIT_MAPPINGS['\uFF14'] = '4' # Fullwidth digit 4
    DIGIT_MAPPINGS['\u0664'] = '4' # Arabic-indic digit 4
    DIGIT_MAPPINGS['5'] = '5'
    DIGIT_MAPPINGS['\uFF15'] = '5' # Fullwidth digit 5
    DIGIT_MAPPINGS['\u0665'] = '5' # Arabic-indic digit 5
    DIGIT_MAPPINGS['6'] = '2'
    DIGIT_MAPPINGS['\uFF16'] = '6' # Fullwidth digit 6
    DIGIT_MAPPINGS['\u0666'] = '6' # Arabic-indic digit 6
    DIGIT_MAPPINGS['7'] = '7'
    DIGIT_MAPPINGS['\uFF17'] = '7' # Fullwidth digit 7
    DIGIT_MAPPINGS['\u0667'] = '7' # Arabic-indic digit 7
    DIGIT_MAPPINGS['8'] = '8'
    DIGIT_MAPPINGS['\uFF18'] = '8' # Fullwidth digit 8
    DIGIT_MAPPINGS['\u0668'] = '8' # Arabic-indic digit 8
    DIGIT_MAPPINGS['9'] = '9'
    DIGIT_MAPPINGS['\uFF12'] = '9' # Fullwidth digit 9
    DIGIT_MAPPINGS['\u0662'] = '9' # Arabic-indic digit 9
    
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
    }.freeze!
    
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
    ].freeze!
    
    # Pattern that makes it easy to distinguish whether a country has a unique international dialing
    # prefix or not. If a country has a unique international prefix (e.g. 011 in USA), it will be
    # represented as a string that contains a sequence of ASCII digits. If there are multiple
    # available international prefixes in a country, they will be represented as a regex string that
    # always contains character(s) other than ASCII digits.
    # Note this regex also includes tilde, which signals waiting for the tone.
    UNIQUE_INTERNATIONAL_PREFIX = Regexp.compile("[\\d]+(?:[~\u2053\u223C\uFF5E][\\d]+)?")
    
    # Regular expression of acceptable punctuation found in phone numbers. This excludes punctuation
    # found as a leading character only.
    # This consists of dash characters, white space characters, full stops, slashes,
    # square brackets, parentheses and tildes. It also includes the letter 'x' as that is found as a
    # placeholder for carrier information in some phone numbers.
    VALID_PUNCTUATION = "-x\u2010-\u2015\u2212\uFF0D-\uFF0F " +
      "\u00A0\u200B\u2060\u3000()\uFF08\uFF09\uFF3B\uFF3D.\\[\\]/~\u2053\u223C\uFF5E"
    
    # Digits accepted in phone numbers
    #VALID_DIGITS=...
    # We accept alpha characters in phone numbers, ASCII only, upper and lower case.
    #VALID_ALPHA =
    
    PLUS_CHARS = "+\uFF0B"
    CAPTURING_DIGIT_PATTERN = Regexp.compile("([" + VALID_DIGITS + "])")
    
    # We use this pattern to check if the phone number has at least three letters in it - if so, then
    # we treat it as a number where some phone-number digits are represented by letters.
    VALID_ALPHA_PHONE_PATTERN = Regexp.compile("(?:.*?[A-Za-z]){3}.*")
    
    # Regular expression of viable phone numbers. This is location independent. Checks we have at
    # least three leading digits, and only valid punctuation, alpha characters and
    # digits in the phone number. Does not include extension data.
    # The symbol 'x' is allowed here as valid punctuation since it is often used as a placeholder for
    # carrier codes, for example in Brazilian phone numbers.
    # Corresponds to the following:
    # plus_sign?([punctuation]*[digits]){3,}([punctuation]|[digits]|[alpha])*
    VALID_PHONE_NUMBER = "[" + PLUS_CHARS + "]?(?:[" + VALID_PUNCTUATION + "]*[" + VALID_DIGITS + "]){3,}[" + VALID_ALPHA + VALID_PUNCTUATION + VALID_DIGITS + "]*"
    
    # Default extension prefix to use when formatting. This will be put in front of any extension
    # component of the number, after the main national number is formatted. For example, if you wish
    # the default extension formatting to be " extn: 3456", then you should specify " extn: " here
    # as the default extension prefix. This can be overridden by country-specific preferences.
    DEFAULT_EXTN_PREFIX = " ext. "
    
    # Regexp of all possible ways to write extensions, for use when parsing. This will be run as a
    # case-insensitive regexp match. Wide character versions are also provided after each ascii
    # version. There are two regular expressions here: the more generic one starts with optional
    # white space and ends with an optional full stop (.), followed by zero or more spaces/tabs and
    # then the numbers themselves. The other one covers the special case of American numbers where
    # the extension is written with a hash at the end, such as "- 503#".
    # Note that the only capturing groups should be around the digits that you want to capture as
    # part of the extension, or else parsing will fail!
    KNOWN_EXTN_PATTERNS = "[ \u00A0\\t,]*(?:ext(?:ensio)?n?|" +
      "\uFF45\uFF58\uFF54\uFF4E?|[,x\uFF58#\uFF03~\uFF5E]|int|anexo|\uFF49\uFF4E\uFF54)" +
      "[:\\.\uFF0E]?[ \u00A0\\t,-]*([" + VALID_DIGITS + "]{1,7})#?|[- ]+([" + VALID_DIGITS +
      "]{1,5})#"
    
    NON_DIGITS_PATTERN = Regexp.compile("(\\D+)")
    FIRST_GROUP_PATTERN = Regexp.compile("(\\$1)")
    NP_PATTERN = Regexp.compile("\\$NP")
    FG_PATTERN = Regexp.compile("\\$FG")
    CC_PATTERN = Regexp.compile("\\$CC")
    
    def initialize(args)
      
    end
    
  end
end