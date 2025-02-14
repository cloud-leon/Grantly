import 'package:flutter/material.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Scholarship Preferences',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPreferenceSection(
              'Basic Filters',
              [
                _buildPreferenceRow('Award Amount', '\$500 - \$50,000', true),
                _buildPreferenceRow('Deadline', 'Next 3 months', true),
                _buildPreferenceRow('Education Level', 'Undergraduate', true),
              ],
            ),
            _buildDivider(),
            _buildPreferenceSection(
              'Academic',
              [
                _buildPreferenceRow('Major', 'Computer Science', true),
                _buildPreferenceRow('GPA', '3.0+', true),
                _buildPreferenceRow('Year in School', 'Junior', true),
              ],
            ),
            _buildDivider(),
            // Container(
            //   margin: const EdgeInsets.all(16),
            //   padding: const EdgeInsets.all(20),
            //   decoration: BoxDecoration(
            //     gradient: const LinearGradient(
            //       colors: [Color(0xFF7B4DFF), Color(0xFF4D9FFF)],
            //       begin: Alignment.topLeft,
            //       end: Alignment.bottomRight,
            //     ),
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       const Row(
            //         children: [
            //           Icon(Icons.star, color: Colors.white, size: 24),
            //           SizedBox(width: 8),
            //           Text(
            //             'Pro Filters',
            //             style: TextStyle(
            //               color: Colors.white,
            //               fontSize: 20,
            //               fontWeight: FontWeight.bold,
            //             ),
            //           ),
            //         ],
            //       ),
            //       const SizedBox(height: 16),
            //       ElevatedButton(
            //         onPressed: () {
            //           // Handle upgrade
            //           Navigator.pop(context);
            //         },
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: Colors.white,
            //           foregroundColor: const Color(0xFF7B4DFF),
            //           padding: const EdgeInsets.symmetric(
            //             horizontal: 24,
            //             vertical: 12,
            //           ),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(25),
            //           ),
            //         ),
            //         child: const Text(
            //           'Unlock Pro Filters',
            //           style: TextStyle(
            //             fontSize: 16,
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            _buildPreferenceSection(
              'Demographics',
              [
                _buildPreferenceRow('Ethnicity', 'All', true),
                _buildPreferenceRow('First Generation', 'Yes', true),
                _buildPreferenceRow('Military Status', 'None', true),
                _buildPreferenceRow('Disability Status', 'None', true),
              ],
            ),
            _buildDivider(),
            _buildPreferenceSection(
              'Interests',
              [
                _buildPreferenceRow('Fields of Study', 'All', true),
                _buildPreferenceRow('Career Goals', 'All', true),
                _buildPreferenceRow('Extracurriculars', 'All', true),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildPreferenceRow(String label, String value, bool isUnlocked) {
    return InkWell(
      onTap: isUnlocked ? () {} : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isUnlocked)
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              )
            else
              const Icon(
                Icons.lock,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 8,
      color: Colors.grey.shade100,
    );
  }
} 