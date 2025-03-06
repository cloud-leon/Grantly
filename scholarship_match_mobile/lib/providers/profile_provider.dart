import 'package:flutter/foundation.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  Profile? _profile;
  final ProfileService _profileService = ProfileService();
  bool _isLoading = false;
  String? _error;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final profile = await _profileService.getProfile();
      _profile = profile;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setProfile(Profile profile) {
    _profile = profile;
    notifyListeners();
  }

  void clearProfile() {
    _profile = null;
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedProfile = await _profileService.updateProfile(profileData);
      _profile = updatedProfile;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 