import 'package:flutter/material.dart';
import '../../widgets/phone_input_widget.dart';
import '../../services/auth_service.dart';
import '../../utils/country_codes.dart';
import '../../screens/auth/otp_verification_screen.dart';
import '../../screens/home/home_screen.dart';

class PhoneViewScreen extends StatefulWidget {
  const PhoneViewScreen({super.key});

  @override
  State<PhoneViewScreen> createState() => _PhoneViewScreenState();
}

class _PhoneViewScreenState extends State<PhoneViewScreen> {
  final AuthService _authService = AuthService();
  bool _canContinue = false;
  String _phoneNumber = '';
  CountryCode _selectedCountry = CountryCodes.countries.first;

  void _handlePhoneChanged(String value) {
    setState(() {
      _phoneNumber = value;
      _canContinue = value.length >= 10;
    });
  }

  void _handleCountryChanged(CountryCode country) {
    setState(() {
      _selectedCountry = country;
    });
  }

  Future<void> _verifyPhoneNumber() async {
    // Temporarily bypass Firebase verification and go directly to OTP screen
    // Comment out the original Firebase code for later
    /*
    await _authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: (String verificationId) {
        // Original navigation code
      },
      onError: (String error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      },
    );
    */
    
    // Directly navigate to OTP screen for UI development
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPVerificationScreen(
          verificationId: 'dummy-verification-id',
          phoneNumber: _phoneNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              PhoneInputWidget(
                onPhoneChanged: _handlePhoneChanged,
                onCountryChanged: _handleCountryChanged,
                initialCountryCode: 'US',
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _canContinue
                        ? () async {
                            final fullNumber = '${_selectedCountry.code}$_phoneNumber';
                            // await _authService.verifyPhoneNumber(
                            //   phoneNumber: fullNumber,
                            //   onCodeSent: (String verificationId) {
                            //     Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (context) => OTPVerificationScreen(
                            //           phoneNumber: fullNumber,
                            //           verificationId: verificationId,
                            //         ),
                            //       ),
                            //     );
                            //   },
                            //   onError: (String error) {
                            //     ScaffoldMessenger.of(context).showSnackBar(
                            //       SnackBar(content: Text(error)),
                            //     );
                            //   },
                            // );
                            await _verifyPhoneNumber();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B4DFF),
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Send Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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
