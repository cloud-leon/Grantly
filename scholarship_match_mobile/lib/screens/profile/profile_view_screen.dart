import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

class ProfileViewScreen extends StatelessWidget {
  const ProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                'Personal Information',
                [
                  _buildInfoRow('First Name', 'Levi'),
                  _buildInfoRow('Last Name', 'Makwei'),
                  _buildInfoRow('Gender', 'Male'),
                  _buildInfoRow('Date of Birth', '01/01/2000'),
                  _buildInfoRow('Email', 'levi.makwei@example.com'),
                  _buildInfoRow('Phone', '(123) 456-7890'),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Academic Information',
                [
                  _buildInfoRow('Education Level', 'Undergraduate'),
                  _buildInfoRow('Major', 'Computer Science'),
                  _buildInfoRow('GPA', '3.8'),
                  _buildInfoRow('Expected Graduation', 'Spring 2025'),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Demographics',
                [
                  _buildInfoRow('First Generation', 'Yes'),
                  _buildInfoRow('Military Status', 'None'),
                  _buildInfoRow('Disability Status', 'None'),
                  _buildInfoRow('Race', 'Asian'),
                  _buildInfoRow('Citizenship', 'United States'),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Interests',
                [
                  _buildInfoRow('Fields of Study', 'Technology, Engineering'),
                  _buildInfoRow('Career Goals', 'Software Development'),
                ],
              ),
              const SizedBox(height: 24), // Add extra padding at bottom
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7B4DFF),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
} 