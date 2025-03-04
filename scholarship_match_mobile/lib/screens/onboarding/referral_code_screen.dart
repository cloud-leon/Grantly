import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/hear_about_us_screen.dart';
import '../../providers/onboarding_provider.dart';
import '../../services/profile_service.dart';
import 'dart:async';  // Add this import for Timer
import '../../utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/screens/loading_screen.dart';

class ReferralCodeScreen extends StatefulWidget {
  const ReferralCodeScreen({super.key});

  @override
  State<ReferralCodeScreen> createState() => _ReferralCodeScreenState();
}

class _ReferralCodeScreenState extends State<ReferralCodeScreen> {
  final TextEditingController _referralController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;
  Timer? _focusTimer;
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _focusTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });

    // Get saved referral code from provider
    final onboardingData = context.read<OnboardingProvider>().onboardingData;
    if (onboardingData['referral_code']?.isNotEmpty ?? false) {
      _referralController.text = onboardingData['referral_code'];
    }
  }

  @override
  void dispose() {
    _focusTimer?.cancel();
    _referralController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submitProfile() async {
    setState(() => _isLoading = true);

    try {
      // Save referral code to provider (for future use if needed)
      final code = _referralController.text.trim();
      context.read<OnboardingProvider>().updateField('referral_code', code);

      // Get all onboarding data
      final onboardingData = context.read<OnboardingProvider>().onboardingData;

      // Create profile data map with only the fields expected by profile service
      final profileData = {
        'first_name': onboardingData['first_name'],
        'last_name': onboardingData['last_name'],
        'date_of_birth': onboardingData['date_of_birth'],
        'email': onboardingData['email'],
        'phone_number': onboardingData['phone_number'],
        'gender': onboardingData['gender'],
        'race': onboardingData['race'],
        'disabilities': onboardingData['disabilities'],
        'military': onboardingData['military'],
        'grade_level': onboardingData['grade_level'],
        'financial_aid': onboardingData['financial_aid'],
        'first_gen': onboardingData['first_gen'],
        'citizenship': onboardingData['citizenship'],
      };

      // Create profile using service with filtered data
      await _profileService.createProfile(profileData);

      if (mounted) {
        // Show loading screen briefly
        NavigationUtils.onNext(context, const LoadingScreen());
        
        // Delay to show loading animation
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          // Navigate to home screen
          Navigator.pushNamedAndRemoveUntil(
            context, 
            '/home',
            (route) => false, // Clear navigation stack
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating profile: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingInputScreen(
      title: 'Have a referral code?',
      subtitle: 'Enter it here to get started.',
      inputField: TextField(
        controller: _referralController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: 'Enter referral code (optional)',
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      previousScreen: const HearAboutUsScreen(),
      onNext: _isLoading ? null : _submitProfile,
      isNextEnabled: !_isLoading,
      nextButtonText: 'Finish',
    );
  }
} 