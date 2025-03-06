import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/last_name_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/email_screen.dart';
import '../../providers/onboarding_provider.dart';
import 'package:intl/intl.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';

class DOBScreen extends StatefulWidget {
  const DOBScreen({super.key});

  @override
  State<DOBScreen> createState() => _DOBScreenState();
}

class _DOBScreenState extends State<DOBScreen> {
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    // Get saved date from provider
    final onboardingData = context.read<OnboardingProvider>().onboardingData;
    if (onboardingData['date_of_birth'] != null) {
      selectedDate = DateTime.parse(onboardingData['date_of_birth']);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey[800],
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _saveAndContinue() {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your date of birth')),
      );
      return;
    }

    // Save to provider
    context.read<OnboardingProvider>().updateField(
      'date_of_birth',
      DateFormat('yyyy-MM-dd').format(selectedDate!),
    );

    // Navigate to next screen
    NavigationUtils.pushReplacementWithoutAnimation(context, const EmailScreen());
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingInputScreen(
      title: 'When\'s your birthday?',
      subtitle: 'We\'ll use this to find age-appropriate scholarships.',
      inputField: Column(
        children: [
          Container(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _selectDate(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                selectedDate == null
                    ? 'Select Date'
                    : DateFormat('MMMM d, yyyy').format(selectedDate!),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (selectedDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'Age: ${DateTime.now().year - selectedDate!.year}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      previousScreen: const LastNameScreen(),
      onNext: _saveAndContinue,
      isNextEnabled: selectedDate != null,
    );
  }
} 