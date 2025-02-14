import 'package:flutter/material.dart';

class ProUpgradeModal extends StatefulWidget {
  const ProUpgradeModal({super.key});

  @override
  State<ProUpgradeModal> createState() => _ProUpgradeModalState();
}

class _ProUpgradeModalState extends State<ProUpgradeModal> {
  bool _isWeeklySelected = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Grantly',
                        style: TextStyle(
                          color: Color(0xFF7B4DFF),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: 'PRO',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 40), // Balance the close button
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Find and Apply to your perfect scholarship',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildFeatureRow('Unlimited Scholarship Matches'),
                const SizedBox(height: 16),
                _buildFeatureRow('AI Essay Review Assistant'),
                const SizedBox(height: 16),
                _buildFeatureRow('Priority Application Support'),
                const SizedBox(height: 16),
                _buildFeatureRow('Early Access to New Features'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildPlanCard(
                    'Weekly',
                    '\$14.99',
                    'Billed Weekly',
                    isSelected: _isWeeklySelected,
                    onTap: () => setState(() => _isWeeklySelected = true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPlanCard(
                    'Monthly',
                    '\$39.99',
                    'Save \$20.00',
                    isSelected: !_isWeeklySelected,
                    onTap: () => setState(() => _isWeeklySelected = false),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                // Handle subscription
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B4DFF),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'Subscribe',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: const Color(0xFF7B4DFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(String title, String price, String subtitle,
      {required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF7B4DFF) : Colors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF7B4DFF) : Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected ? const Color(0xFF7B4DFF) : Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 