import 'package:flutter/material.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_text_field.dart';
import 'package:scholarship_match_mobile/screens/onboarding/email_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/dob_screen.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _canProceed = false;
  String selectedCountry = 'US';
  String selectedCode = '+1';

  final List<Map<String, dynamic>> countries = [
    {'code': '+1', 'name': 'United States', 'shortName': 'US', 'flag': '🇺🇸'},
    {'code': '+93', 'name': 'Afghanistan', 'shortName': 'AF', 'flag': '🇦🇫'},
    {'code': '+355', 'name': 'Albania', 'shortName': 'AL', 'flag': '🇦🇱'},
    {'code': '+213', 'name': 'Algeria', 'shortName': 'DZ', 'flag': '🇩🇿'},
    {'code': '+376', 'name': 'Andorra', 'shortName': 'AD', 'flag': '🇦🇩'},
    {'code': '+244', 'name': 'Angola', 'shortName': 'AO', 'flag': '🇦🇴'},
    {'code': '+1-268', 'name': 'Antigua and Barbuda', 'shortName': 'AG', 'flag': '🇦🇬'},
    {'code': '+54', 'name': 'Argentina', 'shortName': 'AR', 'flag': '🇦🇷'},
    {'code': '+374', 'name': 'Armenia', 'shortName': 'AM', 'flag': '🇦🇲'},
    {'code': '+61', 'name': 'Australia', 'shortName': 'AU', 'flag': '🇦🇺'},
    {'code': '+43', 'name': 'Austria', 'shortName': 'AT', 'flag': '🇦🇹'},
    {'code': '+994', 'name': 'Azerbaijan', 'shortName': 'AZ', 'flag': '🇦🇿'},
    {'code': '+1-242', 'name': 'Bahamas', 'shortName': 'BS', 'flag': '🇧🇸'},
    // Add more countries as needed
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final phoneNumber = _controller.text.trim();
    setState(() {
      _canProceed = phoneNumber.length >= 10;
    });
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                'Select a Country Code',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Search countries',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[400],
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: countries.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final country = countries[index];
                  return ListTile(
                    leading: Text(
                      country['flag']!,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      country['name']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    trailing: Text(
                      country['code']!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        selectedCountry = country['shortName']!;
                        selectedCode = country['code']!;
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingInputScreen(
      title: 'What\'s your\nphone number?',
      subtitle: 'We\'ll use this to verify your account.',
      inputField: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
              hintText: '(123) 456-7890',
              keyboardType: TextInputType.phone,
            ),
          ),
        ],
      ),
      previousScreen: const EmailScreen(),
      onNext: () {
        NavigationUtils.onNext(context, const DOBScreen());
      },
      isNextEnabled: _canProceed,
    );
  }
}