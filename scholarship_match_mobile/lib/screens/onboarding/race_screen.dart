import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/gender_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/disabilities_screen.dart';
import '../../providers/onboarding_provider.dart';
import '../../utils/navigation_utils.dart';

class RaceScreen extends StatefulWidget {
  const RaceScreen({super.key});

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> {
  String? selectedRace;
  final List<String> raceOptions = [
    'White/Caucasian',
    'Black/African American',
    'Asian',
    'Hispanic',
    'Native American / Pacific Islander',
    'Two or more races',
    'Other',
    'Prefer not to say'
  ];

  @override
  void initState() {
    super.initState();
    // Get saved race from provider
    final onboardingData = context.read<OnboardingProvider>().onboardingData;
    if (onboardingData['race']?.isNotEmpty ?? false) {
      selectedRace = onboardingData['race'];
    }
  }

  void _saveAndContinue() {
    if (selectedRace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your race/ethnicity')),
      );
      return;
    }

    // Save to provider
    context.read<OnboardingProvider>().updateField('race', selectedRace);

    // Navigate to next screen with instant transition
    NavigationUtils.onNext(context, const DisabilitiesScreen());
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingInputScreen(
      title: 'What\'s your race/ethnicity?',
      subtitle: 'We\'ll use this to find relevant scholarships.',
      inputField: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: ListView.builder(
          itemCount: raceOptions.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) {
            final race = raceOptions[index];
            return SelectionButton(
              text: race,
              isSelected: selectedRace == race,
              onTap: () {
                setState(() {
                  selectedRace = race;
                });
              },
            );
          },
        ),
      ),
      previousScreen: const GenderScreen(),
      onNext: _saveAndContinue,
      isNextEnabled: selectedRace != null,
      nextButtonText: 'NEXT',
    );
  }
} 