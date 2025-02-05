import 'package:flutter/material.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_text_field.dart';
import 'package:scholarship_match_mobile/screens/onboarding/email_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/gender_screen.dart';
import 'dart:async';

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
    // Add more countries as needed
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_validateInput);
    _focusTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _focusTimer?.cancel();
    _controller.removeListener(_validateInput);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
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
    final phone = _controller.text.trim();
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    
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
        if (formattedNumber != phone) {
          _controller.value = TextEditingValue(
            text: formattedNumber,
            selection: TextSelection.collapsed(offset: formattedNumber.length),
          );
        }
      }
    });
  }

  void _showCountryPicker() {
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
      onNext: () {
        NavigationUtils.onNext(context, const GenderScreen());
      },
      isNextEnabled: _canProceed,
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