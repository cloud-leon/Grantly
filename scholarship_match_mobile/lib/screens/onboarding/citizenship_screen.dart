import 'package:flutter/material.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/widgets/selection_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/phone_number_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/gender_screen.dart';

class CitizenshipScreen extends StatelessWidget {
  const CitizenshipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SelectionScreen(
      title: 'What is your\ncitizenship status?',
      subtitle: 'We will filter scholarships based on your citizenship status.',
      options: const [
        'US Citizen',
        'US Permanent Resident',
        'International',
        'Other',
      ],
      previousScreen: const PhoneNumberScreen(),
      onNext: (selectedOption) {
        NavigationUtils.onNext(context, const GenderScreen());
      },
    );
  }
} 