import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/hear_about_us_screen.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/profile_service.dart';
import 'dart:async';  // Add this import for Timer
import '../../utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/screens/loading_screen.dart';
import '../../models/profile.dart';  // Add this if needed

class ReferralCodeScreen extends StatefulWidget {
  const ReferralCodeScreen({super.key});

  @override
  State<ReferralCodeScreen> createState() => _ReferralCodeScreenState();
}

class _ReferralCodeScreenState extends State<ReferralCodeScreen> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _error;

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
      
      // Get the created profile
      final profile = await profileService.getProfile();
      if (profile != null) {
        print('Profile created successfully: ${profile.toJson()}');
        
        // Store the profile in the provider
        profileProvider.setProfile(profile);
        
        // Clear onboarding data
        onboardingProvider.clear();
        
        // Navigate to home screen and remove all previous routes
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating profile: ${e.toString()}')),
      );
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
    return Scaffold(
      appBar: AppBar(title: Text('Referral Code')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Referral Code (Optional)',
                errorText: _error,
              ),
            ),
            SizedBox(height: 20),
            if (_isLoading)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () => _createProfile(context),
                child: Text('Complete Profile'),
              ),
          ],
        ),
      ),
    );
  }
} 