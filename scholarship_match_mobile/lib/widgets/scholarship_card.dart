import 'package:flutter/material.dart';

class ScholarshipCard extends StatelessWidget {
  final String name;
  final String organization;
  final String amount;
  final String location;
  final List<String> tags;
  final bool showApplyOverlay;
  final bool showPassOverlay;
  const ScholarshipCard({
    super.key,
    required this.name,
    required this.organization,
    required this.amount,
    required this.location,
    required this.tags,
    this.showApplyOverlay = false,
    this.showPassOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        SizedBox(
          width: size.width * 0.9,
          height: size.height * 0.75,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            elevation: 8,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B4DFF), Color(0xFF4D9FFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    organization,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_money,
                        color: Colors.white70,
                        size: 24,
                      ),
                      Text(
                        amount,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '📍 $location',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: tags.map((tag) => Chip(
                      label: Text(
                        tag,
                        style: const TextStyle(fontSize: 14),
                      ),
                      backgroundColor: Colors.white,
                      labelStyle: const TextStyle(
                        color: Color(0xFF7B4DFF),
                        fontWeight: FontWeight.w500,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showApplyOverlay)
          Positioned(
            top: 50,
            left: 25,
            child: Transform.rotate(
              angle: -0.4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF4CD964),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'APPLY',
                  style: TextStyle(
                    color: Color(0xFF4CD964),
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        if (showPassOverlay)
          Positioned(
            top: 50,
            right: 25,
            child: Transform.rotate(
              angle: 0.4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFFF3B30),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Decline',
                  style: TextStyle(
                    color: Color(0xFFFF3B30),
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
} 