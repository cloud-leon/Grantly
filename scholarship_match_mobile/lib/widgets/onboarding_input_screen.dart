import 'package:flutter/material.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';

class OnboardingInputScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget inputField;
  final Widget previousScreen;
  final VoidCallback onNext;
  final bool isNextEnabled;

  const OnboardingInputScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.inputField,
    required this.previousScreen,
    required this.onNext,
    required this.isNextEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF7B4DFF), // Deep purple
              Color(0xFF4D9FFF), // Light blue
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.08,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                  onPressed: () => NavigationUtils.onBack(context, previousScreen),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          title,
                          style: textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontSize: size.width * 0.08,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: size.height * 0.01),
                        // Subtitle
                        Text(
                          subtitle,
                          style: textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: size.width * 0.045,
                          ),
                        ),
                        SizedBox(height: size.height * 0.04),
                        // Input field
                        inputField,
                      ],
                    ),
                  ),
                ),
                // Next button container
                Padding(
                  padding: EdgeInsets.only(
                    bottom: bottomInset + size.height * 0.02,
                  ),
                  child: SizedBox(
                    height: size.height * 0.065,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isNextEnabled ? onNext : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF7B4DFF),
                        disabledBackgroundColor: Colors.white.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: const Text('NEXT'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 