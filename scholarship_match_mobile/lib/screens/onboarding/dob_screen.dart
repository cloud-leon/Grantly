import 'package:flutter/material.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_input_screen.dart';
import 'package:scholarship_match_mobile/widgets/onboarding_text_field.dart';
import 'package:scholarship_match_mobile/screens/onboarding/phone_number_screen.dart';
import 'package:scholarship_match_mobile/screens/onboarding/citizenship_screen.dart';
import 'package:intl/intl.dart';

class DOBScreen extends StatefulWidget {
  const DOBScreen({super.key});

  @override
  State<DOBScreen> createState() => _DOBScreenState();
}

class _DOBScreenState extends State<DOBScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _canProceed = false;
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // Start at 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.white, // Selected date color
              onPrimary: Colors.black, // Selected date text color
              surface: Color(0xFF7B4DFF), // Dialog background
              onSurface: Colors.white, // Calendar text color
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _controller.text = DateFormat('MM/dd/yyyy').format(picked);
        _canProceed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingInputScreen(
      title: 'When\'s your\nbirthday?',
      subtitle: 'We\'ll use this to find age-specific scholarships.',
      inputField: GestureDetector(
        onTap: () => _selectDate(context),
        child: AbsorbPointer(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'MM/DD/YYYY',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 18,
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
      previousScreen: const PhoneNumberScreen(),
      onNext: () {
        NavigationUtils.onNext(context, const CitizenshipScreen());
      },
      isNextEnabled: _canProceed,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
} 