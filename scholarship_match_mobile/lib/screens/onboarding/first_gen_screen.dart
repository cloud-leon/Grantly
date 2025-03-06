import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/financial_aid_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/citizenship_screen.dart';
import '../../providers/onboarding_provider.dart';
import '../../utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/widgets/selection_button.dart';
class FirstGenScreen extends StatefulWidget {
  const FirstGenScreen({super.key});

  @override
  State<FirstGenScreen> createState() => _FirstGenScreenState();
}

class _FirstGenScreenState extends State<FirstGenScreen> {
  String? selectedFirstGen;
  final List<String> firstGenOptions = [
    'Yes',
    'No',
    'Prefer not to say'
  ];

  @override
  void initState() {
    super.initState();
    // Get saved first gen status from provider
    final onboardingData = context.read<OnboardingProvider>().onboardingData;
    if (onboardingData['first_gen']?.toString().isNotEmpty ?? false) {
      // Convert boolean to string option if needed
      if (onboardingData['first_gen'] is bool) {
        selectedFirstGen = onboardingData['first_gen'] ? 'Yes' : 'No';
      } else {
        selectedFirstGen = onboardingData['first_gen'];
      }
    }
  }

  void _saveAndContinue() {
    if (selectedFirstGen == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your first-generation status')),
      );
      return;
    }

    // Save to provider - convert to boolean if Yes/No
    final value = selectedFirstGen == 'Yes' ? true :
                 selectedFirstGen == 'No' ? false :
                 selectedFirstGen;
    context.read<OnboardingProvider>().updateField('first_gen', value);

    // Navigate to next screen with instant transition
    NavigationUtils.onNext(context, const CitizenshipScreen());
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingInputScreen(
      title: 'Are you a first-generation student?',
      subtitle: 'First-generation means neither of your parents completed a 4-year college degree.',
      inputField: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        child: ListView.builder(
          itemCount: firstGenOptions.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) {
            final option = firstGenOptions[index];
            return SelectionButton(
              text: option,
              isSelected: selectedFirstGen == option,
              onTap: () {
                setState(() {
                  selectedFirstGen = option;
                });
              },
            );
          },
        ),
      ),
      previousScreen: const FinancialAidScreen(),
      onNext: _saveAndContinue,
      isNextEnabled: selectedFirstGen != null,
      nextButtonText: 'NEXT',
    );
  }
}
