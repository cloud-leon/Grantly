import 'package:flutter/material.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/widgets/selection_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/first_gen_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/military_screen.dart';

class FinancialAidScreen extends StatelessWidget {
  const FinancialAidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SelectionScreen(
      title: 'Are you eligible for\nfinancial aid?',
      subtitle: 'We will use this to find need-based scholarships.',
      options: const [
        'Yes',
        'No',
        'I don\'t know',
        'Prefer not to say',
      ],
      previousScreen: const FirstGenScreen(),
      onNext: (selectedOption) {
        NavigationUtils.onNext(context, const MilitaryScreen());
      },
    );
  }
} 