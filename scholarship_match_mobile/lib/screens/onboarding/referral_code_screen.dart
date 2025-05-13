import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/hear_about_us_screen.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/profile_service.dart';
import 'dart:async';
import '../../utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/screens/loading_screen.dart';

class ReferralCodeScreen extends StatefulWidget {
  const ReferralCodeScreen({super.key});

  @override
  State<ReferralCodeScreen> createState() => _ReferralCodeScreenState();
}

class _ReferralCodeScreenState extends State<ReferralCodeScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;
  String? _error;
  Timer? _focusTimer;

  @override
  void initState() {
    super.initState();
    _focusTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
  }

  @override
  void dispose() {
    _focusTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _createProfile(BuildContext context) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final onboardingProvider = context.read<OnboardingProvider>();
      final profileProvider = context.read<ProfileProvider>();
      final profileService = ProfileService();

      final Map<String, dynamic> profileData = {
        ...onboardingProvider.getData(),
        'referral_code': _controller.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      };

      print('Creating profile with data: $profileData');

      await profileService.createProfile(profileData);
      
      final profile = await profileService.getProfile();
      if (profile != null) {
        print('Profile created successfully: ${profile.toJson()}');
        
        profileProvider.setProfile(profile);
        onboardingProvider.clear();
        
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
          );
        }
      } else {
        throw Exception('Profile was created but could not be retrieved');
      }
    } catch (e) {
      print('Error creating profile: $e');
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingInputScreen(
      title: 'Have a referral code?',
      subtitle: 'Enter it here to get extra credits (optional)',
      inputField: Column(
        children: [
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
            decoration: InputDecoration(
              hintText: 'Enter referral code',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 20.0,
              ),
              errorText: _error,
              errorStyle: const TextStyle(fontSize: 16.0),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2.0),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2.0),
              ),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        ],
      ),
      previousScreen: const HearAboutUsScreen(),
      onNext: () => _createProfile(context),
      isNextEnabled: !_isLoading,
      nextButtonText: 'COMPLETE PROFILE',
    );
  }
} 