import 'package:flutter/material.dart';
import 'other_source_bottom_sheet.dart';

class HearAboutUsScreen extends StatelessWidget {
  const HearAboutUsScreen({super.key});

  final List<String> options = const [
    'TikTok',
    'Instagram',
    'Linkedin',
    'Twitter / X',
    'Youtube',
    'Friend',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
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
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                Padding(
                  padding: EdgeInsets.only(
                    top: size.height * 0.02,
                    left: size.width * 0.02,
                  ),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: size.width * 0.03,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                // Title
                Text(
                  'How did you\nhear about us?',
                  style: textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                // Options
                Expanded(
                  child: ListView.builder(
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: size.height * 0.02),
                        child: OutlinedButton(
                          onPressed: () {
                            if (options[index] == 'Other') {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => const OtherSourceBottomSheet(),
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                                ),
                              );
                            } else {
                              Navigator.pushReplacementNamed(context, '/first-name');
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            side: const BorderSide(color: Colors.white, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.02,
                            ),
                          ),
                          child: Text(
                            options[index],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.045,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Question at bottom
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: size.height * 0.03),
                    child: Text(
                      'How did you hear about us?',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: size.width * 0.035,
                      ),
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