import 'package:flutter/material.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/widgets/selection_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/disabilities_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/financial_aid_screen.dart';

class FirstGenScreen extends StatelessWidget {
  const FirstGenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SelectionScreen(
      title: 'Are you a first-generation\ncollege student?',
      subtitle: 'We will use this to find first-generation specific scholarships.',
      options: const [
        'Yes',
        'No',
        'I don\'t know',
        'Prefer not to say',
      ],
      previousScreen: const DisabilitiesScreen(),
      onNext: (selectedOption) {
        NavigationUtils.onNext(context, const FinancialAidScreen());
      },
    );
  }
}
