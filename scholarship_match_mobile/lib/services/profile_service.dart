import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/profile.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';

class ProfileService {
  // For Android emulator and iOS simulator
  final String baseUrl = Platform.isAndroid 
    ? 'http://10.0.2.2:8000/api'  // Android emulator
    : 'http://127.0.0.1:8000/api'; // iOS simulator
  
  final Duration timeout = const Duration(seconds: 10);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _cachedToken;
  DateTime? _tokenExpiry;

  // For iOS simulator
  // final String baseUrl = 'http://127.0.0.1:8000/api/users';
  
  Future<String?> _getAuthToken() async {
    if (_cachedToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
      return _cachedToken;
    }

    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      
      _cachedToken = await user.getIdToken(true);
      _tokenExpiry = DateTime.now().add(const Duration(minutes: 30));
      return _cachedToken;
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    if (token == null) throw Exception('Not authenticated');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<Profile?> getProfile() async {
    try {
      final headers = await _getHeaders();
      print('Getting profile with headers: $headers');
      
      final url = '$baseUrl/users/profile/';
      print('Getting profile from URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(timeout);

      print('Get profile response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final profile = Profile.fromJson(json.decode(response.body));
        print('Found existing profile');
        return profile;
      } else if (response.statusCode == 404) {
        print('No profile found');
        return null;
      }
      throw Exception('Failed to get profile: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('Error in getProfile: $e');
      rethrow;
    }
  }

  Future<Profile> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final headers = await _getHeaders();
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('No user ID found');

      profileData['firebase_uid'] = uid;
      
      final response = await http.patch(
        Uri.parse('$baseUrl/users/profile/update/${profileData['id']}/'),
        headers: headers,
        body: json.encode(profileData),
      );

      if (response.statusCode == 200) {
        return Profile.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<bool> checkServerHealth() async {
    try {
      final url = '$baseUrl/health/';
      print('Checking server health at: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      print('Health check response: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }

  Future<void> createProfile(Map<String, dynamic> profileData) async {
    try {
      final headers = await _getHeaders();
      final user = _auth.currentUser;
      if (user != null) {
        profileData['firebase_uid'] = user.uid;
      }

      // Format phone number
      if (profileData.containsKey('phone_number')) {
        String phone = profileData['phone_number'];
        if (!phone.startsWith('+')) {
          profileData['phone_number'] = '+$phone';
        }
      }

      // Convert boolean values to strings
      final boolFields = ['disabilities', 'military', 'financial_aid', 'first_gen'];
      for (var field in boolFields) {
        if (profileData.containsKey(field)) {
          var value = profileData[field];
          if (value is bool) {
            profileData[field] = value ? 'Yes' : 'No';
          }
        }
      }

      final url = '$baseUrl/users/profile/create/';
      print('Creating profile at URL: $url');
      print('Data: ${json.encode(profileData)}');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(profileData),
      ).timeout(timeout);

      print('Create profile response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        print('Profile created successfully');
        
        // Verify profile was created by getting it
        final profile = await getProfile();
        if (profile == null) {
          throw Exception('Profile creation succeeded but profile not found');
        }
        return;
      }
      throw Exception('Failed to create profile: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('Error in createProfile: $e');
      rethrow;
    }
  }

  Future<String> uploadProfilePicture(File imageFile) async {
    try {
      final headers = await _getHeaders();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/users/profile/upload-picture/'),
      );

      request.headers.addAll(headers);
      request.files.add(await http.MultipartFile.fromPath(
        'profile_picture',
        imageFile.path,
      ));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseData);
        return data['profile_picture_url'];
      } else {
        throw Exception('Failed to upload profile picture: $responseData');
      }
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }
} 