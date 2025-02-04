import 'package:flutter/material.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/widgets/selection_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/military_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/location_screen.dart';

class GradeLevelScreen extends StatelessWidget {
  const GradeLevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SelectionScreen(
      title: 'What is your current\ngrade in school?',
      subtitle: 'We will use this to find grade-specific scholarships.',
      options: const [
        'Not Currently Enrolled/Non-Traditional Student',
        'Pre-High School',
        'High School Freshman (Class of 2028)',
        'High School Sophomore (Class of 2027)',
        'High School Junior (Class of 2026)',
        'High School Senior (Class of 2025)',
        'College Freshman (Class of 2028)',
        'College Sophomore (Class of 2027)',
        'College Junior (Class of 2026)',
        'College Senior (Class of 2025)',
        'Graduate School 1st Year',
        'Graduate School 2nd Year',
        'Graduate School 3rd Year',
        'Graduate School 4th Year',
        'Trade/Tech/Career Student',
      ],
      previousScreen: const MilitaryScreen(),
      onNext: (selectedOption) {
        NavigationUtils.onNext(context, const LocationScreen());
      },
    );
  }
} 