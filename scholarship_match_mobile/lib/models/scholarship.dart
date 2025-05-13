class Scholarship {
  final int id;
  final String name;
  final String organization;
  final String amount;
  final String location;
  final List<String> tags;
  final String purpose;
  final String levelOfStudy;
  final String awardType;
  final String deadline;
  final String focus;
  final String qualifications;
  final String criteria;
  final String duration;
  final String numberOfAwards;
  final String toApply;
  final String contact;
  final String moreInfo;

  Scholarship({
    required this.id,
    required this.name,
    required this.organization,
    required this.amount,
    required this.location,
    required this.tags,
    required this.purpose,
    required this.levelOfStudy,
    required this.awardType,
    required this.deadline,
    required this.focus,
    required this.qualifications,
    required this.criteria,
    required this.duration,
    required this.numberOfAwards,
    required this.toApply,
    required this.contact,
    required this.moreInfo,
  });

  factory Scholarship.fromJson(Map<String, dynamic> json) {
    return Scholarship(
      id: json['id'],
      name: json['name'],
      organization: json['organization'],
      amount: json['award_amount'],
      location: json['location'] ?? 'United States', // Default value
      tags: List<String>.from(json['tags'] ?? []),
      purpose: json['purpose'] ?? '',
      levelOfStudy: json['level_of_study'] ?? '',
      awardType: json['award_type'] ?? '',
      deadline: json['deadline'] ?? '',
      focus: json['focus'] ?? '',
      qualifications: json['qualifications'] ?? '',
      criteria: json['criteria'] ?? '',
      duration: json['duration'] ?? '',
      numberOfAwards: json['number_of_awards'] ?? '',
      toApply: json['to_apply'] ?? '',
      contact: json['contact'] ?? '',
      moreInfo: json['more_info'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'organization': organization,
      'award_amount': amount,
      'location': location,
      'tags': tags,
      'purpose': purpose,
      'level_of_study': levelOfStudy,
      'award_type': awardType,
      'deadline': deadline,
      'focus': focus,
      'qualifications': qualifications,
      'criteria': criteria,
      'duration': duration,
      'number_of_awards': numberOfAwards,
      'to_apply': toApply,
      'contact': contact,
      'more_info': moreInfo,
    };
  }

  Scholarship copyWith({
    int? id,
    String? name,
    String? organization,
    String? amount,
    String? location,
    List<String>? tags,
    String? purpose,
    String? levelOfStudy,
    String? awardType,
    String? deadline,
    String? focus,
    String? qualifications,
    String? criteria,
    String? duration,
    String? numberOfAwards,
    String? toApply,
    String? contact,
    String? moreInfo,
  }) {
    return Scholarship(
      id: id ?? this.id,
      name: name ?? this.name,
      organization: organization ?? this.organization,
      amount: amount ?? this.amount,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      purpose: purpose ?? this.purpose,
      levelOfStudy: levelOfStudy ?? this.levelOfStudy,
      awardType: awardType ?? this.awardType,
      deadline: deadline ?? this.deadline,
      focus: focus ?? this.focus,
      qualifications: qualifications ?? this.qualifications,
      criteria: criteria ?? this.criteria,
      duration: duration ?? this.duration,
      numberOfAwards: numberOfAwards ?? this.numberOfAwards,
      toApply: toApply ?? this.toApply,
      contact: contact ?? this.contact,
      moreInfo: moreInfo ?? this.moreInfo,
    );
  }
}





