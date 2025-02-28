class Profile {
  final int id;
  final String? firebaseUid;
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? bio;
  final String userType;
  final List<String> interests;
  final Map<String, dynamic> education;
  final List<String> skills;
  final String? profilePicture;
  final String? gender;
  final String? race;
  final String? disabilities;
  final String? military;
  final String? gradeLevel;
  final String? financialAid;
  final String? firstGen;
  final String? citizenship;
  final String? fieldOfStudy;
  final String? careerGoals;
  final String? educationLevel;

  Profile({
    required this.id,
    this.firebaseUid,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.bio,
    required this.userType,
    required this.interests,
    required this.education,
    required this.skills,
    this.profilePicture,
    this.gender,
    this.race,
    this.disabilities,
    this.military,
    this.gradeLevel,
    this.financialAid,
    this.firstGen,
    this.citizenship,
    this.fieldOfStudy,
    this.careerGoals,
    this.educationLevel,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      firebaseUid: json['firebase_uid'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      dateOfBirth: json['date_of_birth'] != null 
          ? DateTime.parse(json['date_of_birth']) 
          : null,
      bio: json['bio'],
      userType: json['user_type'] ?? 'student',
      interests: List<String>.from(json['interests'] ?? []),
      education: json['education'] ?? {},
      skills: List<String>.from(json['skills'] ?? []),
      profilePicture: json['profile_picture'],
      gender: json['gender'],
      race: json['race'],
      disabilities: json['disabilities'],
      military: json['military'],
      gradeLevel: json['grade_level'],
      financialAid: json['financial_aid'],
      firstGen: json['first_gen'],
      citizenship: json['citizenship'],
      fieldOfStudy: json['field_of_study'],
      careerGoals: json['career_goals'],
      educationLevel: json['education_level'],
    );
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
    };
  }
} 