import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'package:scholarship_match_mobile/widgets/selection_button.dart';
import 'package:scholarship_match_mobile/screens/onboarding/disabilities_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/grade_level_screen.dart';
import '../../providers/onboarding_provider.dart';
import '../../utils/navigation_utils.dart';

class MilitaryScreen extends StatefulWidget {
  const MilitaryScreen({super.key});

  @override
  State<MilitaryScreen> createState() => _MilitaryScreenState();
}

class _MilitaryScreenState extends State<MilitaryScreen> {
  String? selectedMilitary;
  final List<String> militaryOptions = [
    'Yes',
    'No',
    'Prefer not to say'
  ];

  @override
  void initState() {
    super.initState();
    // Get saved military status from provider
    final onboardingData = context.read<OnboardingProvider>().onboardingData;
    if (onboardingData['military']?.isNotEmpty ?? false) {
      selectedMilitary = onboardingData['military'];
    }
  }

  void _saveAndContinue() {
    if (selectedMilitary == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your military status')),
      );
      return;
    }

    // Save to provider
    context.read<OnboardingProvider>().updateField('military', selectedMilitary);

    // Navigate to next screen
    NavigationUtils.onNext(context, const GradeLevelScreen());
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingInputScreen(
      title: 'Are you a military service member or interested in joining?',
      subtitle: 'We\'ll use this to find military-specific scholarships.',
      inputField: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        child: ListView.builder(
          itemCount: militaryOptions.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) {
            final military = militaryOptions[index];
            return SelectionButton(
              text: military,
              isSelected: selectedMilitary == military,
              onTap: () {
                setState(() {
                  selectedMilitary = military;
                });
              },
            );
          },
        ),
      ),
      previousScreen: const DisabilitiesScreen(),
      onNext: _saveAndContinue,
      isNextEnabled: selectedMilitary != null,
      nextButtonText: 'NEXT',
    );
  }
} 