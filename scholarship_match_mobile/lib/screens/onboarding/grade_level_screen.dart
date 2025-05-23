import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'package:scholarship_match_mobile/widgets/selection_button.dart';
import 'package:scholarship_match_mobile/screens/onboarding/military_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/financial_aid_screen.dart';
import '../../providers/onboarding_provider.dart';
import '../../utils/navigation_utils.dart';

class GradeLevelScreen extends StatefulWidget {
  const GradeLevelScreen({super.key});

  @override
  State<GradeLevelScreen> createState() => _GradeLevelScreenState();
}

class _GradeLevelScreenState extends State<GradeLevelScreen> {
  String? selectedGradeLevel;
  final List<String> gradeLevels = [
    'High School Freshman',
    'High School Sophomore',
    'High School Junior',
    'High School Senior',
    'College Freshman',
    'College Sophomore',
    'College Junior',
    'College Senior',
    'Graduate Student',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    // Get saved grade level from provider
    final onboardingData = context.read<OnboardingProvider>().onboardingData;
    if (onboardingData['grade_level']?.isNotEmpty ?? false) {
      selectedGradeLevel = onboardingData['grade_level'];
    }
  }

  void _saveAndContinue() {
    if (selectedGradeLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your grade level')),
      );
      return;
    }

    // Save to provider
    context.read<OnboardingProvider>().updateField('grade_level', selectedGradeLevel);

    // Navigate to next screen
    NavigationUtils.onNext(context, const FinancialAidScreen());
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingInputScreen(
      title: 'What\'s your grade level?',
      subtitle: 'We\'ll use this to find relevant scholarships.',
      inputField: Container(
        height: MediaQuery.of(context).size.height * 0.5, // Adjust this value as needed
        child: ListView.builder(
          itemCount: gradeLevels.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final gradeLevel = gradeLevels[index];
            return SelectionButton(
              text: gradeLevel,
              isSelected: selectedGradeLevel == gradeLevel,
              onTap: () {
                setState(() {
                  selectedGradeLevel = gradeLevel;
                });
              },
            );
          },
        ),
      ),
      previousScreen: const MilitaryScreen(),
      onNext: _saveAndContinue,
      isNextEnabled: selectedGradeLevel != null,
      nextButtonText: 'NEXT',
    );
  }
} 