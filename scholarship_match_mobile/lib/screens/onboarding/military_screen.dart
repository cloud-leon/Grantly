import 'package:flutter/material.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/widgets/selection_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/financial_aid_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/grade_level_screen.dart';

class MilitaryScreen extends StatelessWidget {
  const MilitaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SelectionScreen(
      title: 'Are you interested in\nmilitary opportunities?',
      subtitle: 'We will use this to find military-related scholarships.',
      options: const [
        'Yes',
        'No',
        'Prefer not to say',
      ],
      previousScreen: const FinancialAidScreen(),
      onNext: (selectedOption) {
        NavigationUtils.onNext(context, const GradeLevelScreen());
      },
    );
  }
} 