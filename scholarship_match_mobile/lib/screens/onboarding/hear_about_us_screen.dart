import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/citizenship_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/referral_code_screen.dart';
import '../../providers/onboarding_provider.dart';
import '../../utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/widgets/selection_button.dart';

class HearAboutUsScreen extends StatefulWidget {
  const HearAboutUsScreen({super.key});

  @override
  State<HearAboutUsScreen> createState() => _HearAboutUsScreenState();
}

class _HearAboutUsScreenState extends State<HearAboutUsScreen> {
  String? selectedSource;
  final List<String> sources = [
    'Social Media',
    'Friend/Family',
    'School Counselor',
    'Teacher',
    'College Fair',
    'Online Search',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    // Get saved source from provider
    final onboardingData = context.read<OnboardingProvider>().onboardingData;
    if (onboardingData['hear_about_us']?.isNotEmpty ?? false) {
      selectedSource = onboardingData['hear_about_us'];
    }
  }

  void _saveAndContinue() {
    if (selectedSource == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select how you heard about us')),
      );
      return;
    }

    // Save to provider
    context.read<OnboardingProvider>().updateField('hear_about_us', selectedSource);

    // Navigate to next screen
    NavigationUtils.onNext(context, const ReferralCodeScreen());
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingInputScreen(
      title: 'How did you hear about us?',
      subtitle: 'Help us understand how students find our platform.',
      inputField: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        child: ListView.builder(
          itemCount: sources.length,
          itemBuilder: (context, index) {
            final source = sources[index];
            return SelectionButton(
              text: source,
              isSelected: selectedSource == source,
              onTap: () {
                setState(() {
                  selectedSource = source;
                });
              },
            );
          },
        ),
      ),
      previousScreen: const CitizenshipScreen(),
      onNext: _saveAndContinue,
      isNextEnabled: selectedSource != null,
    );
  }
} 