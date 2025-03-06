class Profile {
  final int id;
  final String firebaseUid;
  final String firstName;
  final String lastName;
  final DateTime? dateOfBirth;
  final String? bio;
  final String userType;
  final List<String> interests;
  final Map<String, dynamic> education;
  final List<String> skills;
  final String? profilePicture;
  final String email;
  final String phoneNumber;
  final String gender;
  final String race;
  final String disabilities;
  final String military;
  final String gradeLevel;
  final String financialAid;
  final String firstGen;
  final String citizenship;
  final String? fieldOfStudy;
  final String? careerGoals;
  final String? educationLevel;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int credits;
  final String location;
  final String hearAboutUs;
  final String referralCode;
  final int userId;

  Profile({
    required this.id,
    required this.firebaseUid,
    required this.firstName,
    required this.lastName,
    this.dateOfBirth,
    this.bio,
    required this.userType,
    required this.interests,
    required this.education,
    required this.skills,
    this.profilePicture,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    required this.race,
    required this.disabilities,
    required this.military,
    required this.gradeLevel,
    required this.financialAid,
    required this.firstGen,
    required this.citizenship,
    this.fieldOfStudy,
    this.careerGoals,
    this.educationLevel,
    required this.createdAt,
    required this.updatedAt,
    required this.credits,
    required this.location,
    required this.hearAboutUs,
    required this.referralCode,
    required this.userId,
  });

  bool get isComplete {
    final complete = firstName.isNotEmpty && 
           lastName.isNotEmpty &&
           dateOfBirth != null &&
           email.isNotEmpty &&
           phoneNumber.isNotEmpty &&
           gender.isNotEmpty &&
           race.isNotEmpty &&
           gradeLevel.isNotEmpty &&
           citizenship.isNotEmpty &&
           disabilities.isNotEmpty &&
           military.isNotEmpty &&
           financialAid.isNotEmpty &&
           firstGen.isNotEmpty;

    // Debug print to see which fields are missing
    if (!complete) {
      print('Profile incomplete. Missing fields:');
      if (firstName.isEmpty) print('- First name');
      if (lastName.isEmpty) print('- Last name');
      if (dateOfBirth == null) print('- Date of birth');
      if (email.isEmpty) print('- Email');
      if (phoneNumber.isEmpty) print('- Phone number');
      if (gender.isEmpty) print('- Gender');
      if (race.isEmpty) print('- Race');
      if (gradeLevel.isEmpty) print('- Grade level');
      if (citizenship.isEmpty) print('- Citizenship');
      if (disabilities.isEmpty) print('- Disabilities');
      if (military.isEmpty) print('- Military');
      if (financialAid.isEmpty) print('- Financial aid');
      if (firstGen.isEmpty) print('- First gen');
    }

    return complete;
  }

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      firebaseUid: json['firebase_uid'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth']) : null,
      bio: json['bio'],
      userType: json['user_type'] ?? 'student',
      interests: List<String>.from(json['interests'] ?? []),
      education: json['education'] ?? {},
      skills: List<String>.from(json['skills'] ?? []),
      profilePicture: json['profile_picture'],
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      gender: json['gender'] ?? '',
      race: json['race'] ?? '',
      disabilities: _boolToString(json['disabilities']),
      military: _boolToString(json['military']),
      gradeLevel: json['grade_level'] ?? '',
      financialAid: _boolToString(json['financial_aid']),
      firstGen: _boolToString(json['first_gen']),
      citizenship: json['citizenship'] ?? '',
      fieldOfStudy: json['field_of_study'],
      careerGoals: json['career_goals'],
      educationLevel: json['education_level'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      credits: json['credits'] ?? 3,
      location: json['location'] ?? '',
      hearAboutUs: json['hear_about_us'] ?? '',
      referralCode: json['referral_code'] ?? '',
      userId: json['user'],
    );
  }

  static String _boolToString(dynamic value) {
    if (value is bool) {
      return value ? 'Yes' : 'No';
    }
    if (value is String) {
      return value;
    }
    return 'No';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebase_uid': firebaseUid,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'bio': bio,
      'user_type': userType,
      'interests': interests,
      'education': education,
      'skills': skills,
      'profile_picture': profilePicture,
      'email': email,
      'phone_number': phoneNumber,
      'gender': gender,
      'race': race,
      'disabilities': disabilities,
      'military': military,
      'grade_level': gradeLevel,
      'financial_aid': financialAid,
      'first_gen': firstGen,
      'citizenship': citizenship,
      'field_of_study': fieldOfStudy,
      'career_goals': careerGoals,
      'education_level': educationLevel,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'credits': credits,
      'location': location,
      'hear_about_us': hearAboutUs,
      'referral_code': referralCode,
      'user': userId,
    };
  }

  Profile copyWith(Map<String, dynamic> updates) {
    return Profile(
      id: id,
      firebaseUid: firebaseUid,
      firstName: updates['firstName'] ?? firstName,
      lastName: updates['lastName'] ?? lastName,
      dateOfBirth: updates['dateOfBirth'] ?? dateOfBirth,
      bio: bio,
      userType: userType,
      interests: interests,
      education: education,
      skills: skills,
      profilePicture: profilePicture,
      email: email,
      phoneNumber: phoneNumber,
      gender: gender,
      race: race,
      disabilities: disabilities,
      military: military,
      gradeLevel: gradeLevel,
      financialAid: financialAid,
      firstGen: firstGen,
      citizenship: citizenship,
      fieldOfStudy: fieldOfStudy,
      careerGoals: careerGoals,
      educationLevel: educationLevel,
      createdAt: createdAt,
      updatedAt: updatedAt,
      credits: credits,
      location: location,
      hearAboutUs: hearAboutUs,
      referralCode: referralCode,
      userId: userId,
    );
  }
} 