import 'package:flutter/material.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/screens/onboarding/email_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/gender_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/citizenship_screen.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  String selectedCountryCode = '+1';
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool isKeyboardVisible = false;
  bool _canProceed = false;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _countries = [
    {'name': 'United States', 'code': '+1'},
    {'name': 'United Kingdom', 'code': '+44'},
    {'name': 'Canada', 'code': '+1'},
    {'name': 'Australia', 'code': '+61'},
    {'name': 'India', 'code': '+91'},
    // Add more countries
  ];
  List<Map<String, String>> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    _filteredCountries = _countries;
    _focusNode.addListener(_onFocusChange);
    _phoneController.addListener(_onTextChanged);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onTextChanged);
    _phoneController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      isKeyboardVisible = _focusNode.hasFocus;
    });
  }

  void _onTextChanged() {
    setState(() {
      _canProceed = _phoneController.text.trim().length >= 10;
    });
  }

  void _filterCountries(String query) {
    setState(() {
      _filteredCountries = _countries
          .where((country) =>
              country['name']!.toLowerCase().contains(query.toLowerCase()) ||
              country['code']!.contains(query))
          .toList();
    });
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _filterCountries(value);
                    });
                  },
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search country or code',
                    hintStyle: TextStyle(
                      color: Colors.grey[600],
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[600],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF7B4DFF)),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredCountries.length,
                  itemBuilder: (context, index) {
                    final country = _filteredCountries[index];
                    return ListTile(
                      title: Text(country['name']!),
                      trailing: Text(
                        country['code']!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          selectedCountryCode = country['code']!;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF7B4DFF),
              Color(0xFF4D9FFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () => NavigationUtils.onBack(context, const EmailScreen()),
                    ),
                    SizedBox(height: size.height * 0.04),
                    Text(
                      'What is your\nphone number?',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),
                    Row(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.white),
                            ),
                          ),
                          child: TextButton(
                            onPressed: _showCountryPicker,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'US',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: size.width * 0.045,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  selectedCountryCode,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: size.width * 0.045,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: size.width * 0.04),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            focusNode: _focusNode,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.045,
                            ),
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: 'Enter phone number',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: size.width * 0.045,
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.02),
                    Text(
                      'This phone number will be used on your applications.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: size.width * 0.035,
                      ),
                    ),
                  ],
                ),
              ),
              // Next Button
              Positioned(
                left: size.width * 0.08,
                right: size.width * 0.08,
                bottom: keyboardHeight + 20,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: !_canProceed
                        ? null
                        : () {
                            NavigationUtils.onNext(context, const CitizenshipScreen());
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: Colors.white.withOpacity(0.3),
                      disabledForegroundColor: Colors.white.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                    ),
                    child: const Text('NEXT'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}