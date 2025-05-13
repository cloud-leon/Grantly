import 'package:flutter/foundation.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  Profile? _profile;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetched;
  final Duration _cacheTimeout = const Duration(minutes: 5);

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final ProfileService _profileService = ProfileService();

  bool get shouldRefresh {
    if (_lastFetched == null) return true;
    return DateTime.now().difference(_lastFetched!) > _cacheTimeout;
  }

  void setProfile(Profile profile) {
    _profile = profile;
    _lastFetched = DateTime.now();
    _error = null;
    notifyListeners();
  }

  Future<void> fetchProfile({bool force = false}) async {
    if (!force && !shouldRefresh && _profile != null) {
      return; // Use cached data
    }

    if (_isLoading) return; // Prevent multiple simultaneous fetches

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final profile = await _profileService.getProfile();
      if (profile != null) {
        _profile = profile;
        _lastFetched = DateTime.now();
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error fetching profile: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      _isLoading = true;
      notifyListeners();

      final updatedProfile = await _profileService.updateProfile(updates);
      _profile = updatedProfile;
      _lastFetched = DateTime.now();
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error updating profile: $_error');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearProfile() {
    _profile = null;
    _lastFetched = null;
    _error = null;
    notifyListeners();
  }
} 