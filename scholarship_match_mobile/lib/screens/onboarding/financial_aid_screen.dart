import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/grade_level_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/first_gen_screen.dart';
import '../../providers/onboarding_provider.dart';
import '../../utils/navigation_utils.dart';
class FinancialAidScreen extends StatefulWidget {
  const FinancialAidScreen({super.key});

  @override
  State<FinancialAidScreen> createState() => _FinancialAidScreenState();
}

class _FinancialAidScreenState extends State<FinancialAidScreen> {
  String? selectedFinancialAid;
  final List<String> financialAidOptions = [
    'Yes',
    'No',
    'Prefer not to say'
  ];

  @override
  void initState() {
    super.initState();
    // Get saved financial aid status from provider
    final onboardingData = context.read<OnboardingProvider>().onboardingData;
    if (onboardingData['financial_aid']?.isNotEmpty ?? false) {
      selectedFinancialAid = onboardingData['financial_aid'];
    }
  }

  void _saveAndContinue() {
    if (selectedFinancialAid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your financial aid status')),
      );
      return;
    }

    // Save to provider
    context.read<OnboardingProvider>().updateField('financial_aid', selectedFinancialAid);

    // Navigate to next screen
    NavigationUtils.onNext(context, const FirstGenScreen());
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingInputScreen(
      title: 'Do you receive financial aid?',
      subtitle: 'We\'ll use this to find need-based scholarships.',
      inputField: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        child: ListView.builder(
          itemCount: financialAidOptions.length,
          itemBuilder: (context, index) {
            final aid = financialAidOptions[index];
            return ListTile(
              title: Text(
                aid,
                style: TextStyle(
                  color: selectedFinancialAid == aid
                      ? Theme.of(context).primaryColor
                      : Colors.white,
                ),
              ),
              onTap: () {
                setState(() {
                  selectedFinancialAid = aid;
                });
              },
              trailing: selectedFinancialAid == aid
                  ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
            );
          },
        ),
      ),
      previousScreen: const GradeLevelScreen(),
      onNext: _saveAndContinue,
      isNextEnabled: selectedFinancialAid != null,
    );
  }
} 