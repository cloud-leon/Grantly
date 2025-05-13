import 'package:flutter/material.dart';
import '../../widgets/scholarship_card.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../screens/home/preferences_screen.dart';
import '../../providers/profile_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _dragOffset = 0;
  bool _isDragging = false;
  bool _showApplyOverlay = false;
  bool _showPassOverlay = false;
  Offset _dragStartPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    
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
        leading: IconButton(
          icon: const Icon(Icons.flash_on, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.grey),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PreferencesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Draggable(
                feedback: Transform.translate(
                  offset: Offset(_dragOffset, 0),
                  child: ScholarshipCard(
                    name: 'Gates Millennium Scholars Program',
                    organization: 'Bill & Melinda Gates Foundation',
                    amount: '50,000',
                    location: 'United States',
                    tags: const ['Full Ride', 'Undergraduate', 'STEM', 'Merit-based', 'New', "dodd"],
                    showApplyOverlay: _dragOffset > 0,
                    showPassOverlay: _dragOffset < 0,
                  ),
                ),
                childWhenDragging: Container(),
                onDragStarted: () {
                  setState(() {
                    _isDragging = true;
                    _dragStartPosition = Offset.zero;
                  });
                },
                onDragUpdate: (details) {
                  setState(() {
                    if (_dragStartPosition == Offset.zero) {
                      _dragStartPosition = details.globalPosition;
                    }
                    _dragOffset = details.globalPosition.dx - _dragStartPosition.dx;
                  });
                },
                onDragEnd: (details) {
                  setState(() {
                    _isDragging = false;
                    _dragOffset = 0;
                    _dragStartPosition = Offset.zero;
                    
                    if (details.velocity.pixelsPerSecond.dx > 0) {
                      print('Liked');
                      _showApplyOverlay = true;
                      _showPassOverlay = false;
                    } else if (details.velocity.pixelsPerSecond.dx < 0) {
                      print('Passed');
                      _showApplyOverlay = false;
                      _showPassOverlay = true;
                    } else {
                      _showApplyOverlay = false;
                      _showPassOverlay = false;
                    }
                  });
                },
                child: ScholarshipCard(
                  name: 'Gates Millennium Scholars Program',
                  organization: 'Bill & Melinda Gates Foundation',
                  amount: '50,000',
                  location: 'United States',
                  tags: const ['Full Ride', 'Undergraduate', 'STEM', 'Merit-based', 'New'],
                  showApplyOverlay: _showApplyOverlay,
                  showPassOverlay: _showPassOverlay,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
} 