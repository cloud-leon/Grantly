import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OnboardingProvider extends ChangeNotifier {
  final Map<String, dynamic> _onboardingData = {};
  String? _uid;

  Map<String, dynamic> get onboardingData => _onboardingData;
  String? get uid => _uid;

  void setUid(String uid) {
    _uid = uid;
    notifyListeners();
  }

  void updateField(String field, dynamic value) {
    _onboardingData[field] = value;
    notifyListeners();
  }

  void clearData() {
    _onboardingData.clear();
    _uid = null;
    notifyListeners();
  }

  bool get isComplete {
    return _onboardingData.values.every((value) => 
      value != null && 
      (value is! String || value.isNotEmpty)
    );
  }

  void reset() {
    _onboardingData.clear();
    _uid = null;
    notifyListeners();
  }

  Map<String, dynamic> getData() {
    return {
      'first_name': _onboardingData['first_name'] ?? '',
      'last_name': _onboardingData['last_name'] ?? '',
      'date_of_birth': _onboardingData['date_of_birth'] ?? '',
      'email': _onboardingData['email'] ?? '',
      'phone_number': _onboardingData['phone_number'] ?? '',
      'gender': _onboardingData['gender'] ?? '',
      'race': _onboardingData['race'] ?? '',
      'disabilities': _onboardingData['disabilities'] ?? false,
      'military': _onboardingData['military'] ?? false,
      'grade_level': _onboardingData['grade_level'] ?? '',
      'financial_aid': _onboardingData['financial_aid'] ?? false,
      'first_gen': _onboardingData['first_gen'] ?? false,
      'citizenship': _onboardingData['citizenship'] ?? '',
      'hear_about_us': _onboardingData['hear_about_us'] ?? '',
      'referral_code': _onboardingData['referral_code'] ?? '',
    };
  }

  void clear() {
    _onboardingData.clear();
    _uid = null;
    notifyListeners();
  }
} 