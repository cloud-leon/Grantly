import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/profile.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';

class ProfileService {
  final String baseUrl = '${ApiConstants.baseUrl}/api/auth';
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getAccessToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<Profile> getProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/profile/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Profile.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to load profile: $e');
    }
  }

  Future<Profile> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/profile/update/${profileData['id']}/'),
        headers: headers,
        body: json.encode(profileData),
      );

      if (response.statusCode == 200) {
        return Profile.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<Profile> createProfile(Map<String, dynamic> profileData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/profile/create/'),
        headers: headers,
        body: json.encode(profileData),
      );

      if (response.statusCode == 201) {
        return Profile.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to create profile: $e');
    }
  }

  Future<String> uploadProfilePicture(File imageFile) async {
    try {
      final headers = await _getHeaders();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/profile/upload-picture/'),
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