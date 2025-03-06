import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../providers/profile_provider.dart';
import '../../services/profile_service.dart';

class ProfileViewScreen extends StatelessWidget {
  const ProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final profileService = ProfileService();

    Future<void> _updateField(String field, String currentValue) async {
      final result = await showDialog<String>(
        context: context,
        builder: (context) => EditDialog(
          title: field,
          initialValue: currentValue,
        ),
      );

      if (result != null && result != currentValue && profile != null) {
        try {
          final updatedProfile = await profileService.updateProfile({
            'id': profile.id,
            field: result,
          });
          if (context.mounted) {
            context.read<ProfileProvider>().setProfile(updatedProfile);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update profile: $e')),
            );
          }
        }
      }
    }

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
                  _buildEditableRow('First Name', profile?.firstName ?? '', () => _updateField('firstName', profile?.firstName ?? '')),
                  _buildEditableRow('Last Name', profile?.lastName ?? '', () => _updateField('lastName', profile?.lastName ?? '')),
                  _buildEditableRow('Gender', profile?.gender ?? '', () => _updateField('gender', profile?.gender ?? '')),
                  _buildEditableRow('Date of Birth', profile?.dateOfBirth?.toString().split(' ')[0] ?? '', () => _updateField('dateOfBirth', profile?.dateOfBirth?.toString() ?? '')),
                  _buildEditableRow('Email', profile?.email ?? '', () => _updateField('email', profile?.email ?? '')),
                  _buildEditableRow('Phone', profile?.phoneNumber ?? '', () => _updateField('phoneNumber', profile?.phoneNumber ?? '')),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Academic Information',
                [
                  _buildEditableRow('Education Level', profile?.educationLevel ?? '', () => _updateField('educationLevel', profile?.educationLevel ?? '')),
                  _buildEditableRow('Field of Study', profile?.fieldOfStudy ?? '', () => _updateField('fieldOfStudy', profile?.fieldOfStudy ?? '')),
                  _buildEditableRow('Grade Level', profile?.gradeLevel ?? '', () => _updateField('gradeLevel', profile?.gradeLevel ?? '')),
                  _buildEditableRow('Career Goals', profile?.careerGoals ?? '', () => _updateField('careerGoals', profile?.careerGoals ?? '')),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Demographics',
                [
                  _buildEditableRow('First Generation', profile?.firstGen ?? '', () => _updateField('firstGen', profile?.firstGen ?? '')),
                  _buildEditableRow('Military Status', profile?.military ?? '', () => _updateField('military', profile?.military ?? '')),
                  _buildEditableRow('Disability Status', profile?.disabilities ?? '', () => _updateField('disabilities', profile?.disabilities ?? '')),
                  _buildEditableRow('Race', profile?.race ?? '', () => _updateField('race', profile?.race ?? '')),
                  _buildEditableRow('Citizenship', profile?.citizenship ?? '', () => _updateField('citizenship', profile?.citizenship ?? '')),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                'Interests & Skills',
                [
                  _buildEditableRow('Interests', (profile?.interests ?? []).join(', '), () => _updateField('interests', (profile?.interests ?? []).join(', '))),
                  _buildEditableRow('Skills', (profile?.skills ?? []).join(', '), () => _updateField('skills', (profile?.skills ?? []).join(', '))),
                ],
              ),
              const SizedBox(height: 24),
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

  Widget _buildEditableRow(String label, String value, VoidCallback onEdit) {
    return InkWell(
      onTap: onEdit,
      child: Container(
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
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
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.edit,
                    size: 16,
                    color: Color(0xFF7B4DFF),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditDialog extends StatefulWidget {
  final String title;
  final String initialValue;

  const EditDialog({
    super.key,
    required this.title,
    required this.initialValue,
  });

  @override
  State<EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.title}'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Enter ${widget.title.toLowerCase()}',
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}