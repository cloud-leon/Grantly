import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/first_gen_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/hear_about_us_screen.dart';
import '../../providers/onboarding_provider.dart';
import '../../utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/widgets/selection_button.dart';
class CitizenshipScreen extends StatefulWidget {
  const CitizenshipScreen({super.key});

  @override
  State<CitizenshipScreen> createState() => _CitizenshipScreenState();
}

class _CitizenshipScreenState extends State<CitizenshipScreen> {
  String? selectedCitizenship;
  final List<String> citizenshipOptions = [
    'US Citizen',
    'US Permanent Resident',
    'International',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    // Get saved citizenship status from provider
    final onboardingData = context.read<OnboardingProvider>().onboardingData;
    if (onboardingData['citizenship']?.isNotEmpty ?? false) {
      selectedCitizenship = onboardingData['citizenship'];
    }
  }

  void _saveAndContinue() {
    if (selectedCitizenship == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your citizenship status')),
      );
      return;
    }

    // Save to provider
    context.read<OnboardingProvider>().updateField('citizenship', selectedCitizenship);

    // Navigate to next screen
    NavigationUtils.onNext(context, const HearAboutUsScreen());
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingInputScreen(
      title: 'What\'s your citizenship status?',
      subtitle: 'We\'ll use this to find scholarships you\'re eligible for.',
      inputField: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        child: ListView.builder(
          itemCount: citizenshipOptions.length,
          itemBuilder: (context, index) {
            final citizenship = citizenshipOptions[index];
            return SelectionButton(
              text: citizenship,
              isSelected: selectedCitizenship == citizenship,
              onTap: () {
                setState(() {
                  selectedCitizenship = citizenship;
                });
              },
            );
          },
        ),
      ),
      previousScreen: const FirstGenScreen(),
      onNext: _saveAndContinue,
      isNextEnabled: selectedCitizenship != null,
    );
  }
} 