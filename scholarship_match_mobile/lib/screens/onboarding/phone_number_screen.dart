import 'package:flutter/material.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_text_field.dart';
import 'package:scholarship_match_mobile/screens/onboarding/email_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/gender_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/dob_screen.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _searchFocusNode = FocusNode();
  bool _canProceed = false;
  String? _errorText;
  Timer? _focusTimer;
  Timer? _debounceTimer;
  String selectedCountry = 'US';
  String selectedCode = '+1';

  // Regular expression for US phone numbers
  static final RegExp _phoneRegex = RegExp(
    r'^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$', 
  );

  final List<Map<String, String>> countries = [
    {'code': '+1', 'name': 'United States', 'shortName': 'US', 'flag': '🇺🇸'},
    {'code': '+93', 'name': 'Afghanistan', 'shortName': 'AF', 'flag': '🇦🇫'},
    {'code': '+355', 'name': 'Albania', 'shortName': 'AL', 'flag': '🇦🇱'},
    {'code': '+213', 'name': 'Algeria', 'shortName': 'DZ', 'flag': '🇩🇿'},
    {'code': '+376', 'name': 'Andorra', 'shortName': 'AD', 'flag': '🇦🇩'},
    {'code': '+244', 'name': 'Angola', 'shortName': 'AO', 'flag': '🇦🇴'},
    {'code': '+1-268', 'name': 'Antigua and Barbuda', 'shortName': 'AG', 'flag': '🇦🇬'},
    {'code': '+54', 'name': 'Argentina', 'shortName': 'AR', 'flag': '🇦🇷'},
    {'code': '+374', 'name': 'Armenia', 'shortName': 'AM', 'flag': '🇦🇲'},
    {'code': '+297', 'name': 'Aruba', 'shortName': 'AW', 'flag': '🇦🇼'},
    {'code': '+61', 'name': 'Australia', 'shortName': 'AU', 'flag': '🇦🇺'},
    {'code': '+43', 'name': 'Austria', 'shortName': 'AT', 'flag': '🇦🇹'},
    {'code': '+994', 'name': 'Azerbaijan', 'shortName': 'AZ', 'flag': '🇦🇿'},
    {'code': '+1-242', 'name': 'Bahamas', 'shortName': 'BS', 'flag': '🇧🇸'},
    {'code': '+973', 'name': 'Bahrain', 'shortName': 'BH', 'flag': '🇧🇭'},
    {'code': '+880', 'name': 'Bangladesh', 'shortName': 'BD', 'flag': '🇧🇩'},
    {'code': '+1-246', 'name': 'Barbados', 'shortName': 'BB', 'flag': '🇧🇧'},
    {'code': '+375', 'name': 'Belarus', 'shortName': 'BY', 'flag': '🇧🇾'},
    {'code': '+32', 'name': 'Belgium', 'shortName': 'BE', 'flag': '🇧🇪'},
    {'code': '+501', 'name': 'Belize', 'shortName': 'BZ', 'flag': '🇧🇿'},
    {'code': '+229', 'name': 'Benin', 'shortName': 'BJ', 'flag': '🇧🇯'},
    {'code': '+1-441', 'name': 'Bermuda', 'shortName': 'BM', 'flag': '🇧🇲'},
    {'code': '+975', 'name': 'Bhutan', 'shortName': 'BT', 'flag': '🇧🇹'},
    {'code': '+591', 'name': 'Bolivia', 'shortName': 'BO', 'flag': '🇧🇴'},
    {'code': '+387', 'name': 'Bosnia and Herzegovina', 'shortName': 'BA', 'flag': '🇧🇦'},
    {'code': '+267', 'name': 'Botswana', 'shortName': 'BW', 'flag': '🇧🇼'},
    {'code': '+55', 'name': 'Brazil', 'shortName': 'BR', 'flag': '🇧🇷'},
    {'code': '+673', 'name': 'Brunei', 'shortName': 'BN', 'flag': '🇧🇳'},
    {'code': '+359', 'name': 'Bulgaria', 'shortName': 'BG', 'flag': '🇧🇬'},
    {'code': '+226', 'name': 'Burkina Faso', 'shortName': 'BF', 'flag': '🇧🇫'},
    {'code': '+257', 'name': 'Burundi', 'shortName': 'BI', 'flag': '🇧🇮'},
    {'code': '+855', 'name': 'Cambodia', 'shortName': 'KH', 'flag': '🇰🇭'},
    {'code': '+237', 'name': 'Cameroon', 'shortName': 'CM', 'flag': '🇨🇲'},
    {'code': '+1', 'name': 'Canada', 'shortName': 'CA', 'flag': '🇨🇦'},
    {'code': '+238', 'name': 'Cape Verde', 'shortName': 'CV', 'flag': '🇨🇻'},
    {'code': '+1-345', 'name': 'Cayman Islands', 'shortName': 'KY', 'flag': '🇰🇾'},
    {'code': '+236', 'name': 'Central African Republic', 'shortName': 'CF', 'flag': '🇨🇫'},
    {'code': '+235', 'name': 'Chad', 'shortName': 'TD', 'flag': '🇹🇩'},
    {'code': '+56', 'name': 'Chile', 'shortName': 'CL', 'flag': '🇨🇱'},
    {'code': '+86', 'name': 'China', 'shortName': 'CN', 'flag': '🇨🇳'},
    {'code': '+61', 'name': 'Christmas Island', 'shortName': 'CX', 'flag': '🇨🇽'},
    {'code': '+61', 'name': 'Cocos (Keeling) Islands', 'shortName': 'CC', 'flag': '🇨🇨'},
    {'code': '+57', 'name': 'Colombia', 'shortName': 'CO', 'flag': '🇨🇴'},
    {'code': '+269', 'name': 'Comoros', 'shortName': 'KM', 'flag': '🇰🇲'},
    {'code': '+242', 'name': 'Congo', 'shortName': 'CG', 'flag': '🇨🇬'},
    {'code': '+243', 'name': 'Congo, Democratic Republic of the', 'shortName': 'CD', 'flag': '🇨🇩'},
    {'code': '+682', 'name': 'Cook Islands', 'shortName': 'CK', 'flag': '🇨🇰'},
    {'code': '+506', 'name': 'Costa Rica', 'shortName': 'CR', 'flag': '🇨🇷'},
    {'code': '+385', 'name': 'Croatia', 'shortName': 'HR', 'flag': '🇭🇷'},
    {'code': '+53', 'name': 'Cuba', 'shortName': 'CU', 'flag': '🇨🇺'},
    {'code': '+357', 'name': 'Cyprus', 'shortName': 'CY', 'flag': '🇨🇾'},
    {'code': '+420', 'name': 'Czechia', 'shortName': 'CZ', 'flag': '🇨🇿'},
    {'code': '+45', 'name': 'Denmark', 'shortName': 'DK', 'flag': '🇩🇰'},
    {'code': '+253', 'name': 'Djibouti', 'shortName': 'DJ', 'flag': '🇩🇯'},
    {'code': '+1-767', 'name': 'Dominica', 'shortName': 'DM', 'flag': '🇩🇲'},
    {'code': '+1-809', 'name': 'Dominican Republic', 'shortName': 'DO', 'flag': '🇩🇴'},
    {'code': '+691', 'name': 'Micronesia', 'shortName': 'FM', 'flag': '🇫🇲'},
    {'code': '+373', 'name': 'Moldova', 'shortName': 'MD', 'flag': '🇲🇩'},
    {'code': '+377', 'name': 'Monaco', 'shortName': 'MC', 'flag': '🇲🇨'},
    {'code': '+976', 'name': 'Mongolia', 'shortName': 'MN', 'flag': '🇲🇳'},
    {'code': '+382', 'name': 'Montenegro', 'shortName': 'ME', 'flag': '🇲🇪'},
    {'code': '+1-664', 'name': 'Montserrat', 'shortName': 'MS', 'flag': '🇲🇸'},
    {'code': '+212', 'name': 'Morocco', 'shortName': 'MA', 'flag': '🇲🇦'},
    {'code': '+258', 'name': 'Mozambique', 'shortName': 'MZ', 'flag': '🇲🇿'},
    {'code': '+95', 'name': 'Myanmar', 'shortName': 'MM', 'flag': '🇲🇲'},
    {'code': '+264', 'name': 'Namibia', 'shortName': 'NA', 'flag': '🇳🇦'},
    {'code': '+674', 'name': 'Nauru', 'shortName': 'NR', 'flag': '🇳🇷'},
    {'code': '+968', 'name': 'Oman', 'shortName': 'OM', 'flag': '🇴🇲'},
    {'code': '+92', 'name': 'Pakistan', 'shortName': 'PK', 'flag': '🇵🇰'},
    {'code': '+680', 'name': 'Palau', 'shortName': 'PW', 'flag': '🇵🇼'},
    {'code': '+970', 'name': 'Palestinian Territory, Occupied', 'shortName': 'PS', 'flag': '🇵🇸'},
    {'code': '+507', 'name': 'Panama', 'shortName': 'PA', 'flag': '🇵🇦'},
    {'code': '+675', 'name': 'Papua New Guinea', 'shortName': 'PG', 'flag': '🇵🇬'},
    {'code': '+595', 'name': 'Paraguay', 'shortName': 'PY', 'flag': '🇵🇾'},
    {'code': '+51', 'name': 'Peru', 'shortName': 'PE', 'flag': '🇵🇪'},
    {'code': '+63', 'name': 'Philippines', 'shortName': 'PH', 'flag': '🇵🇭'},
    {'code': '+48', 'name': 'Poland', 'shortName': 'PL', 'flag': '🇵🇱'},
    {'code': '+351', 'name': 'Portugal', 'shortName': 'PT', 'flag': '🇵🇹'},
    {'code': '+1-787', 'name': 'Puerto Rico', 'shortName': 'PR', 'flag': '🇵🇷'},
    {'code': '+974', 'name': 'Qatar', 'shortName': 'QA', 'flag': '🇶🇦'},
    {'code': '+262', 'name': 'Reunion', 'shortName': 'RE', 'flag': '🇷🇪'},
    {'code': '+40', 'name': 'Romania', 'shortName': 'RO', 'flag': '🇷🇴'},
    {'code': '+7', 'name': 'Russia', 'shortName': 'RU', 'flag': '🇷🇺'},
    {'code': '+250', 'name': 'Rwanda', 'shortName': 'RW', 'flag': '🇷🇼'},
    {'code': '+590', 'name': 'Saint Barthelemy', 'shortName': 'BL', 'flag': '🇧🇱'},
    {'code': '+290', 'name': 'Saint Helena, Ascension and Tristan da Cunha', 'shortName': 'SH', 'flag': '🇸🇭'},
    {'code': '+1-758', 'name': 'Saint Lucia', 'shortName': 'LC', 'flag': '🇱🇨'},
    {'code': '+590', 'name': 'Saint Martin', 'shortName': 'MF', 'flag': '🇲🇫'},
    {'code': '+508', 'name': 'Saint Pierre and Miquelon', 'shortName': 'PM', 'flag': '🇵🇲'},
    {'code': '+1-784', 'name': 'Saint Vincent and the Grenadines', 'shortName': 'VC', 'flag': '🇻🇨'},
    {'code': '+685', 'name': 'Samoa', 'shortName': 'WS', 'flag': '🇼🇸'},
    {'code': '+378', 'name': 'San Marino', 'shortName': 'SM', 'flag': '🇸🇲'},
    {'code': '+239', 'name': 'Sao Tome and Principe', 'shortName': 'ST', 'flag': '🇸🇹'},
    {'code': '+966', 'name': 'Saudi Arabia', 'shortName': 'SA', 'flag': '🇸🇦'},
    {'code': '+221', 'name': 'Senegal', 'shortName': 'SN', 'flag': '🇸🇳'},
    {'code': '+381', 'name': 'Serbia', 'shortName': 'RS', 'flag': '🇷🇸'},
    {'code': '+248', 'name': 'Seychelles', 'shortName': 'SC', 'flag': '🇸🇨'},
    {'code': '+232', 'name': 'Sierra Leone', 'shortName': 'SL', 'flag': '🇸🇱'},
    {'code': '+65', 'name': 'Singapore', 'shortName': 'SG', 'flag': '🇸🇬'},
    {'code': '+1-721', 'name': 'Sint Maarten', 'shortName': 'SX', 'flag': '🇸🇽'},
    {'code': '+421', 'name': 'Slovakia', 'shortName': 'SK', 'flag': '🇸🇰'},
    {'code': '+386', 'name': 'Slovenia', 'shortName': 'SI', 'flag': '🇸🇮'},
    {'code': '+677', 'name': 'Solomon Islands', 'shortName': 'SB', 'flag': '🇸🇧'},
    {'code': '+252', 'name': 'Somalia', 'shortName': 'SO', 'flag': '🇸🇴'},
    {'code': '+27', 'name': 'South Africa', 'shortName': 'ZA', 'flag': '🇿🇦'},
    {'code': '+82', 'name': 'South Korea', 'shortName': 'KR', 'flag': '🇰🇷'},
    {'code': '+34', 'name': 'Spain', 'shortName': 'ES', 'flag': '🇪🇸'},
    {'code': '+94', 'name': 'Sri Lanka', 'shortName': 'LK', 'flag': '🇱🇰'},
    {'code': '+249', 'name': 'Sudan', 'shortName': 'SD', 'flag': '🇸🇩'},
    {'code': '+597', 'name': 'Suriname', 'shortName': 'SR', 'flag': '🇸🇷'},
    {'code': '+268', 'name': 'Swaziland', 'shortName': 'SZ', 'flag': '🇸🇿'},
    {'code': '+46', 'name': 'Sweden', 'shortName': 'SE', 'flag': '🇸🇪'},
    {'code': '+41', 'name': 'Switzerland', 'shortName': 'CH', 'flag': '🇨🇭'},
    {'code': '+963', 'name': 'Syria', 'shortName': 'SY', 'flag': '🇸🇾'},
    {'code': '+886', 'name': 'Taiwan', 'shortName': 'TW', 'flag': '🇹🇼'},
    {'code': '+992', 'name': 'Tajikistan', 'shortName': 'TJ', 'flag': '🇹🇯'},
    {'code': '+255', 'name': 'Tanzania', 'shortName': 'TZ', 'flag': '🇹🇿'},
    {'code': '+66', 'name': 'Thailand', 'shortName': 'TH', 'flag': '🇹🇭'}, 
    {'code': '+228', 'name': 'Togo', 'shortName': 'TG', 'flag': '🇹🇬'},      
    {'code': '+690', 'name': 'Tokelau', 'shortName': 'TK', 'flag': '🇹🇰'},
    {'code': '+676', 'name': 'Tonga', 'shortName': 'TO', 'flag': '🇹🇴'},
    {'code': '+1-868', 'name': 'Trinidad and Tobago', 'shortName': 'TT', 'flag': '🇹🇹'},
    {'code': '+216', 'name': 'Tunisia', 'shortName': 'TN', 'flag': '🇹🇳'},
    {'code': '+90', 'name': 'Turkey', 'shortName': 'TR', 'flag': '🇹🇷'},
    {'code': '+993', 'name': 'Turkmenistan', 'shortName': 'TM', 'flag': '🇹🇲'},
    {'code': '+1-649', 'name': 'Turks and Caicos Islands', 'shortName': 'TC', 'flag': '🇹🇨'},
    {'code': '+688', 'name': 'Tuvalu', 'shortName': 'TV', 'flag': '🇹🇻'},
    {'code': '+256', 'name': 'Uganda', 'shortName': 'UG', 'flag': '🇺🇬'},
    {'code': '+380', 'name': 'Ukraine', 'shortName': 'UA', 'flag': '🇺🇦'},
    {'code': '+971', 'name': 'United Arab Emirates', 'shortName': 'AE', 'flag': '🇦🇪'},
    {'code': '+44', 'name': 'United Kingdom', 'shortName': 'GB', 'flag': '🇬🇧'},
    {'code': '+1', 'name': 'United States', 'shortName': 'US', 'flag': '🇺🇸'},
    {'code': '+598', 'name': 'Uruguay', 'shortName': 'UY', 'flag': '🇺🇾'},
    {'code': '+998', 'name': 'Uzbekistan', 'shortName': 'UZ', 'flag': '🇺🇿'},
    {'code': '+678', 'name': 'Vanuatu', 'shortName': 'VU', 'flag': '🇻🇺'},
    {'code': '+58', 'name': 'Venezuela', 'shortName': 'VE', 'flag': '🇻🇪'},
    {'code': '+84', 'name': 'Vietnam', 'shortName': 'VN', 'flag': '🇻🇳'},
    {'code': '+681', 'name': 'Wallis and Futuna', 'shortName': 'WF', 'flag': '🇼🇫'},
    {'code': '+212', 'name': 'Western Sahara', 'shortName': 'EH', 'flag': '🇪🇭'},
    {'code': '+967', 'name': 'Yemen', 'shortName': 'YE', 'flag': '🇾🇪'},
    {'code': '+260', 'name': 'Zambia', 'shortName': 'ZM', 'flag': '🇿🇲'},
    {'code': '+263', 'name': 'Zimbabwe', 'shortName': 'ZW', 'flag': '🇿🇼'},
    {'code': '+1-284', 'name': 'British Virgin Islands', 'shortName': 'VG', 'flag': '🇻🇬'},
    {'code': '+1-340', 'name': 'U.S. Virgin Islands', 'shortName': 'VI', 'flag': '🇻🇮'},
    {'code': '+1-242', 'name': 'Bahamas', 'shortName': 'BS', 'flag': '🇧🇸'},
    // Add more countries as needed
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });

    // Get saved phone number from provider and handle country code
    final onboardingData = context.read<OnboardingProvider>().onboardingData;
    if (onboardingData['phone_number']?.isNotEmpty ?? false) {
      String phoneNumber = onboardingData['phone_number'];
      
      // Extract country code and number
      for (var country in countries) {
        if (phoneNumber.startsWith(country['code']!)) {
          selectedCountry = country['shortName']!;
          selectedCode = country['code']!;
          // Remove country code from phone number
          phoneNumber = phoneNumber.substring(country['code']!.length);
          break;
        }
      }
      
      // Format the remaining number
      if (phoneNumber.length == 10) {
        _controller.text = _formatPhoneNumber(phoneNumber);
        _validateInput();
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _focusTimer?.cancel();
    _controller.removeListener(_onTextChanged);
    _searchFocusNode.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (!mounted) return;
    
    // Cancel any previous debounce timer
    _debounceTimer?.cancel();
    
    // Set a new timer
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _validateInput();
      }
    });
  }

  String _formatPhoneNumber(String text) {
    final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length >= 10) {
      return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6, 10)}';
    } else if (digitsOnly.length > 6) {
      return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
    } else if (digitsOnly.length > 3) {
      return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3)}';
    } else if (digitsOnly.isNotEmpty) {
      return '(${digitsOnly.substring(0)}';
    }
    return digitsOnly;
  }

  void _validateInput() {
    if (!mounted) return;
    
    final phone = _controller.text.trim();
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (!mounted) return;
    setState(() {
      if (phone.isEmpty) {
        _errorText = null;
        _canProceed = false;
      } else if (digitsOnly.length != 10) {
        _errorText = 'Please enter a valid 10-digit phone number';
        _canProceed = false;
      } else if (!_phoneRegex.hasMatch(digitsOnly)) {
        _errorText = 'Please enter a valid phone number';
        _canProceed = false;
      } else {
        _errorText = null;
        _canProceed = true;
        
        final formattedNumber = _formatPhoneNumber(phone);
        if (formattedNumber != phone && mounted) {
          _controller.value = TextEditingValue(
            text: formattedNumber,
            selection: TextSelection.collapsed(offset: formattedNumber.length),
          );
        }
      }
    });
  }

  void _showCountryPicker() {
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return _CountryPickerContent(
              countries: countries,
              onCountrySelected: (country) {
                if (!mounted) return;
                setState(() {
                  selectedCountry = country['shortName']!;
                  selectedCode = country['code']!;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _saveAndContinue() {
    if (!_canProceed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }

    // Save to provider with country code
    final phoneNumber = '$selectedCode${_controller.text.replaceAll(RegExp(r'[^\d]'), '')}';
    context.read<OnboardingProvider>().updateField('phone_number', phoneNumber);

    // Navigate to next screen with instant transition
    NavigationUtils.pushReplacementWithoutAnimation(context, const GenderScreen());
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingInputScreen(
      title: 'What\'s your phone number?',
      subtitle: 'We\'ll text you about new matches.',
      inputField: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _showCountryPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    selectedCountry,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    selectedCode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OnboardingTextField(
              controller: _controller,
              focusNode: _focusNode,
              hintText: '(555) 555-5555',
              errorText: _errorText,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
            ),
          ),
        ],
      ),
      previousScreen: const EmailScreen(),
      onNext: _saveAndContinue,
      isNextEnabled: _canProceed,
      nextButtonText: 'NEXT',
    );
  }
}

class _CountryPickerContent extends StatefulWidget {
  final List<Map<String, String>> countries;
  final Function(Map<String, String>) onCountrySelected;

  const _CountryPickerContent({
    required this.countries,
    required this.onCountrySelected,
  });

  @override
  State<_CountryPickerContent> createState() => _CountryPickerContentState();
}

class _CountryPickerContentState extends State<_CountryPickerContent> {
  late List<Map<String, String>> filteredCountries;
  late TextEditingController _searchController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    filteredCountries = List.from(widget.countries);
    _searchController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (!mounted) return;
    setState(() {
      filteredCountries = widget.countries
          .where((country) =>
              country['name']!
                  .toLowerCase()
                  .contains(value.toLowerCase()) ||
              country['code']!
                  .toLowerCase()
                  .contains(value.toLowerCase()) ||
              country['shortName']!
                  .toLowerCase()
                  .contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            'Select a Country Code',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            autofocus: true,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Search country',
              hintStyle: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade600,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF7B4DFF),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: filteredCountries.length,
            itemBuilder: (context, index) {
              final country = filteredCountries[index];
              return ListTile(
                leading: Text(
                  country['flag']!,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(country['name']!),
                trailing: Text(country['code']!),
                onTap: () => widget.onCountrySelected(country),
              );
            },
          ),
        ),
      ],
    );
  }
}