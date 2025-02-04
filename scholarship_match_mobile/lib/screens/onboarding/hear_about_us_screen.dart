import 'package:flutter/material.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/widgets/selection_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/location_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/referral_code_screen.dart';

class HearAboutUsScreen extends StatelessWidget {
  const HearAboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SelectionScreen(
      title: 'How did you hear\nabout us?',
      subtitle: 'This helps us understand how students find Grantly.',
      options: const [
        'Social Media',
        'Friend or Family',
        'School Counselor',
        'Teacher',
        'College Advisor',
        'Search Engine',
        'App Store',
        'Other',
      ],
      previousScreen: const LocationScreen(),
      onNext: (selectedOption) {
        NavigationUtils.onNext(context, const ReferralCodeScreen());
      },
    );
  }
} 