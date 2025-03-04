import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/dob_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/phone_number_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/race_screen.dart';
import '../../providers/onboarding_provider.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';

class SelectionButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectionButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(30),
            color: isSelected ? Colors.white : Colors.transparent,
          ),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 20.0, // Increased font size
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  String? selectedGender;
  final List<String> genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say'
  ];

  @override
  void initState() {
    super.initState();
    // Get saved gender from provider
    final onboardingData = context.read<OnboardingProvider>().onboardingData;
    if (onboardingData['gender']?.isNotEmpty ?? false) {
      selectedGender = onboardingData['gender'];
    }
  }

  void _saveAndContinue() {
    if (selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your gender')),
      );
      return;
    }

    // Save to provider
    context.read<OnboardingProvider>().updateField('gender', selectedGender);

    // Navigate to next screen with instant transition
    NavigationUtils.pushReplacementWithoutAnimation(context, const RaceScreen());
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingInputScreen(
      title: 'What\'s your gender?',
      subtitle: 'We\'ll use this to find relevant scholarships.',
      inputField: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        child: ListView.builder(
          itemCount: genderOptions.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) {
            final gender = genderOptions[index];
            return SelectionButton(
              text: gender,
              isSelected: selectedGender == gender,
              onTap: () {
                setState(() {
                  selectedGender = gender;
                });
              },
            );
          },
        ),
      ),
      previousScreen: const PhoneNumberScreen(),
      onNext: _saveAndContinue,
      isNextEnabled: selectedGender != null,
      nextButtonText: 'NEXT',
    );
  }
} 