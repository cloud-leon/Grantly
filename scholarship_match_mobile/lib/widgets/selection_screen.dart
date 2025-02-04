import 'package:flutter/material.dart';
import 'package:scholarship_match_mobile/utils/navigation_utils.dart';
import 'package:scholarship_match_mobile/widgets/selection_button.dart';

class SelectionScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<String> options;
  final Widget previousScreen;
  final Function(String) onNext;

  const SelectionScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.previousScreen,
    required this.onNext,
  });

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF7B4DFF),
              Color(0xFF4D9FFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () => NavigationUtils.onBack(
                        context,
                        widget.previousScreen,
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                    ),
                    SizedBox(height: size.height * 0.06),
                    ...widget.options.map((option) => SelectionButton(
                          text: option,
                          isSelected: selectedOption == option,
                          onTap: () {
                            setState(() {
                              selectedOption = option;
                            });
                          },
                        )),
                    const Spacer(),
                  ],
                ),
              ),
              Positioned(
                left: size.width * 0.08,
                right: size.width * 0.08,
                bottom: 20,
                child: Column(
                  children: [
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: size.width * 0.035,
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedOption != null
                            ? () => widget.onNext(selectedOption!)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          disabledBackgroundColor: Colors.white.withOpacity(0.3),
                          disabledForegroundColor: Colors.white.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                        ),
                        child: const Text('NEXT'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 