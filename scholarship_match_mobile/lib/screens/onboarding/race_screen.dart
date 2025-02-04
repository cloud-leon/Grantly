import 'package:flutter/material.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/widgets/selection_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/gender_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/disabilities_screen.dart';

class RaceScreen extends StatelessWidget {
  const RaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SelectionScreen(
      title: 'Race?',
      subtitle: 'We will select this race on your applications.',
      options: const [
        'White/Caucasian',
        'Black/African American',
        'Asian',
        'Hispanic',
        'Native American / Pacific Islander',
        'Two or more races',
        'Other',
        'Prefer not to say',
      ],
      previousScreen: const GenderScreen(),
      onNext: (selectedOption) {
        NavigationUtils.onNext(context, const DisabilitiesScreen());
      },
    );
  }
} 