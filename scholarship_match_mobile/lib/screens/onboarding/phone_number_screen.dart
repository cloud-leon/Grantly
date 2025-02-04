import 'package:flutter/material.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/screens/onboarding/email_screen.dart';

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

  @override
  void initState() {
    super.initState();
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

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            const Text(
              'Select Country Code',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildCountryTile('+1', 'United States'),
                  _buildCountryTile('+44', 'United Kingdom'),
                  _buildCountryTile('+91', 'India'),
                  // Add more country codes as needed
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryTile(String code, String country) {
    return ListTile(
      title: Text('$country ($code)'),
      onTap: () {
        setState(() {
          selectedCountryCode = code;
        });
        Navigator.pop(context);
      },
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
                            // TODO: Navigate to next screen
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