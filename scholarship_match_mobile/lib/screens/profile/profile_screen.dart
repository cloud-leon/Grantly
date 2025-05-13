import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../providers/profile_provider.dart';
import 'profile_view_screen.dart';
import '../../widgets/pro_upgrade_modal.dart';
import 'get_credits_screen.dart';
import 'settings_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Only fetch if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProfileProvider>();
      if (provider.shouldRefresh) {
        provider.fetchProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF7B4DFF), Color(0xFF4D9FFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Grantly',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsView(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (profileProvider.error != null) {
            return Center(child: Text('Error: ${profileProvider.error}'));
          }

          final profile = profileProvider.profile;
          final firstName = profile?.firstName ?? 'User';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        ' 🎓 ',
                        style: TextStyle(
                          fontSize: 32,
                        ),
                      ),
                      const Text(
                        'Hey, ',
                        style: TextStyle(
                          fontSize: 32,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        firstName,
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // Rest of your UI remains the same
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileViewScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.school_outlined),
                          label: const Text('Profile'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF7B4DFF),
                            side: const BorderSide(color: Color(0xFF7B4DFF)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ),
                           const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GetCreditsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_basket_outlined),
                      label: const Text('Get Credits'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF7B4DFF),
                        side: const BorderSide(color: Color(0xFF7B4DFF)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    ),
                    ],
                  ),
                      const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B4DFF), Color(0xFF4D9FFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Grantly Pro',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pro users are 3x more likely to get matched with scholarships',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const ProUpgradeModal(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF7B4DFF),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Upgrade to Pro',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Features:',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Basic',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 32),
                      Text(
                        'Pro',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFeatureRow('Unlimited Scholarship Matches', false, true),
              _buildFeatureRow('Priority Application Support', false, true),
              _buildFeatureRow('AI Essay Review', false, true),
              _buildFeatureRow('Deadline Reminders', false, true),
              _buildFeatureRow('Advanced Search Filters', false, true),
              _buildFeatureRow('Subscription Preferences', false, true),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildFeatureRow(String feature, bool isBasic, bool isPro) {
    // Your existing _buildFeatureRow implementation
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            feature,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          Row(
            children: [
              Icon(
                isBasic ? Icons.check : Icons.circle,
                color: isBasic ? const Color(0xFF7B4DFF) : Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 40),
              Icon(
                isPro ? Icons.check : Icons.circle,
                color: isPro ? const Color(0xFF7B4DFF) : Colors.grey,
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }
} 