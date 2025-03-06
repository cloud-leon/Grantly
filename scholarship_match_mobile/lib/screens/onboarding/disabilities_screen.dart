import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'package:scholarship_match_mobile/widgets/selection_button.dart';
import 'package:scholarship_match_mobile/screens/onboarding/race_screen.dart';
import '../../providers/onboarding_provider.dart';
import 'military_screen.dart';
import '../../utils/navigation_utils.dart';
class DisabilitiesScreen extends StatefulWidget {
  const DisabilitiesScreen({super.key});

  @override
  State<DisabilitiesScreen> createState() => _DisabilitiesScreenState();
}

class _DisabilitiesScreenState extends State<DisabilitiesScreen> {
  String? selectedDisability;
  final List<String> disabilityOptions = [
    'Yes',
    'No',
    'Prefer not to say'
  ];

  @override
  void initState() {
    super.initState();
    // Get saved disability status from provider
    final onboardingData = context.read<OnboardingProvider>().onboardingData;
    if (onboardingData['disabilities']?.isNotEmpty ?? false) {
      selectedDisability = onboardingData['disabilities'];
    }
  }

  void _saveAndContinue() {
    if (selectedDisability == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your disability status')),
      );
      return;
    }

    // Save to provider
    context.read<OnboardingProvider>().updateField('disabilities', selectedDisability);

    // Navigate to next screen with instant transition
    NavigationUtils.onNext(context, const MilitaryScreen());
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingInputScreen(
      title: 'Do you have any disabilities?',
      subtitle: 'We\'ll use this to find relevant scholarships.',
      inputField: Container(
        height: MediaQuery.of(context).size.height * 0.4,  // Shorter height since fewer options
        child: ListView.builder(
          itemCount: disabilityOptions.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) {
            final option = disabilityOptions[index];
            return SelectionButton(
              text: option,
              isSelected: selectedDisability == option,
              onTap: () {
                setState(() {
                  selectedDisability = option;
                });
              },
            );
          },
        ),
      ),
      previousScreen: const RaceScreen(),
      onNext: _saveAndContinue,
      isNextEnabled: selectedDisability != null,
      nextButtonText: 'NEXT',
    );
  }
}