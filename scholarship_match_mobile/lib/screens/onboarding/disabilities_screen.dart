import 'package:flutter/material.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/widgets/selection_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/race_screen.dart';

class DisabilitiesScreen extends StatelessWidget {
  const DisabilitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SelectionScreen(
      title: 'Do you have any\ndisabilities?',
      subtitle: 'We will use this to find disability-specific scholarships.',
      options: const [
        'Yes',
        'No',
        'Prefer not to say',
      ],
      previousScreen: const RaceScreen(),
      onNext: (selectedOption) {
        // TODO: Navigate to next screen
      },
    );
  }
}