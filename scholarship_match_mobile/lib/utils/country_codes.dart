class CountryCode {
  final String code;
  final String name;
  final String shortName;
  final String flag;

  const CountryCode({
    required this.code,
    required this.name,
    required this.shortName,
    required this.flag,
  });
}

class CountryCodes {
  static const List<CountryCode> countries = [
    CountryCode(code: '+1', name: 'United States', shortName: 'US', flag: '🇺🇸'),
    CountryCode(code: '+93', name: 'Afghanistan', shortName: 'AF', flag: '🇦🇫'),
    CountryCode(code: '+355', name: 'Albania', shortName: 'AL', flag: '🇦🇱'),
    CountryCode(code: '+213', name: 'Algeria', shortName: 'DZ', flag: '🇩🇿'),
    CountryCode(code: '+376', name: 'Andorra', shortName: 'AD', flag: '🇦🇩'),
    CountryCode(code: '+244', name: 'Angola', shortName: 'AO', flag: '🇦🇴'),
    CountryCode(code: '+1-268', name: 'Antigua and Barbuda', shortName: 'AG', flag: '🇦🇬'),
    CountryCode(code: '+54', name: 'Argentina', shortName: 'AR', flag: '🇦🇷'),
    CountryCode(code: '+374', name: 'Armenia', shortName: 'AM', flag: '🇦🇲'),
    CountryCode(code: '+297', name: 'Aruba', shortName: 'AW', flag: '🇦🇼'),
    CountryCode(code: '+61', name: 'Australia', shortName: 'AU', flag: '🇦🇺'),
    CountryCode(code: '+43', name: 'Austria', shortName: 'AT', flag: '🇦🇹'),
    CountryCode(code: '+994', name: 'Azerbaijan', shortName: 'AZ', flag: '🇦🇿'), 
    CountryCode(code: '+1-242', name: 'Bahamas', shortName: 'BS', flag: '🇧🇸'),
    CountryCode(code: '+973', name: 'Bahrain', shortName: 'BH', flag: '🇧🇭'),
    CountryCode(code: '+880', name: 'Bangladesh', shortName: 'BD', flag: '🇧🇩'),
    CountryCode(code: '+1-246', name: 'Barbados', shortName: 'BB', flag: '🇧🇧'),
    CountryCode(code: '+375', name: 'Belarus', shortName: 'BY', flag: '🇧🇾'),
    CountryCode(code: '+32', name: 'Belgium', shortName: 'BE', flag: '🇧🇪'),
    CountryCode(code: '+501', name: 'Belize', shortName: 'BZ', flag: '🇧🇿'),
    CountryCode(code: '+229', name: 'Benin', shortName: 'BJ', flag: '🇧🇯'),
    CountryCode(code: '+1-441', name: 'Bermuda', shortName: 'BM', flag: '🇧🇲'),
    CountryCode(code: '+975', name: 'Bhutan', shortName: 'BT', flag: '🇧🇹'),
    CountryCode(code: '+591', name: 'Bolivia', shortName: 'BO', flag: '🇧🇴'),
    CountryCode(code: '+387', name: 'Bosnia and Herzegovina', shortName: 'BA', flag: '🇧🇦'),
    CountryCode(code: '+267', name: 'Botswana', shortName: 'BW', flag: '🇧🇼'),
    CountryCode(code: '+55', name: 'Brazil', shortName: 'BR', flag: '🇧🇷'),
    CountryCode(code: '+246', name: 'British Indian Ocean Territory', shortName: 'IO', flag: '🇮🇴'),
    CountryCode(code: '+673', name: 'Brunei', shortName: 'BN', flag: '🇧🇳'),
    CountryCode(code: '+359', name: 'Bulgaria', shortName: 'BG', flag: '🇧🇬'),
    CountryCode(code: '+226', name: 'Burkina Faso', shortName: 'BF', flag: '🇧🇫'),
    CountryCode(code: '+257', name: 'Burundi', shortName: 'BI', flag: '🇧🇮'),
    CountryCode(code: '+855', name: 'Cambodia', shortName: 'KH', flag: '🇰🇭'),
    CountryCode(code: '+237', name: 'Cameroon', shortName: 'CM', flag: '🇨🇲'),
    CountryCode(code: '+1', name: 'Canada', shortName: 'CA', flag: '🇨🇦'),
    CountryCode(code: '+238', name: 'Cape Verde', shortName: 'CV', flag: '🇨🇻'),
    CountryCode(code: '+1-345', name: 'Cayman Islands', shortName: 'KY', flag: '🇰🇾'),
    CountryCode(code: '+236', name: 'Central African Republic', shortName: 'CF', flag: '🇨🇫'),   
    CountryCode(code: '+235', name: 'Chad', shortName: 'TD', flag: '🇹🇩'),
    CountryCode(code: '+56', name: 'Chile', shortName: 'CL', flag: '🇨🇱'),
    CountryCode(code: '+86', name: 'China', shortName: 'CN', flag: '🇨🇳'),
    CountryCode(code: '+61', name: 'Christmas Island', shortName: 'CX', flag: '🇨🇽'),
    CountryCode(code: '+61', name: 'Cocos (Keeling) Islands', shortName: 'CC', flag: '🇨🇨'),
    CountryCode(code: '+57', name: 'Colombia', shortName: 'CO', flag: '🇨🇴'),    
    CountryCode(code: '+269', name: 'Comoros', shortName: 'KM', flag: '🇰🇲'),
    CountryCode(code: '+242', name: 'Congo', shortName: 'CD', flag: '🇨🇩'),
    CountryCode(code: '+243', name: 'Congo (DRC)', shortName: 'CD', flag: '🇨🇩'),
    CountryCode(code: '+682', name: 'Cook Islands', shortName: 'CK', flag: '🇨🇰'),
    CountryCode(code: '+506', name: 'Costa Rica', shortName: 'CR', flag: '🇨🇷'),
    CountryCode(code: '+385', name: 'Croatia', shortName: 'HR', flag: '🇭🇷'),        
    CountryCode(code: '+53', name: 'Cuba', shortName: 'CU', flag: '🇨🇺'),        
    CountryCode(code: '+357', name: 'Cyprus', shortName: 'CY', flag: '🇨🇾'),         
    CountryCode(code: '+420', name: 'Czechia', shortName: 'CZ', flag: '🇨🇿'),
    CountryCode(code: '+243', name: 'Democratic Republic of the Congo', shortName: 'CD', flag: '🇨🇩'),
    CountryCode(code: '+45', name: 'Denmark', shortName: 'DK', flag: '🇩🇰'),
    CountryCode(code: '+253', name: 'Djibouti', shortName: 'DJ', flag: '🇩🇯'),
    CountryCode(code: '+1-767', name: 'Dominica', shortName: 'DM', flag: '🇩🇲'),
    
    // ... add all other countries
  ];

  static CountryCode getByCode(String code) {
    return countries.firstWhere(
      (country) => country.code == code,
      orElse: () => countries.first,
    );
  }

  static CountryCode getByShortName(String shortName) {
    return countries.firstWhere(
      (country) => country.shortName == shortName,
      orElse: () => countries.first,
    );
  }
} 