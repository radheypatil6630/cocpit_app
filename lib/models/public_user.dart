class PublicUser {
  final String id;
  final String fullName;
  final String? headline;
  final String? avatarUrl;
  final String? location;
  final String? about;

  final List<PublicExperience> experiences;
  final List<PublicEducation> educations;
  final List<String> skills;

  PublicUser({
    required this.id,
    required this.fullName,
    this.headline,
    this.avatarUrl,
    this.location,
    this.about,
    required this.experiences,
    required this.educations,
    required this.skills,
  });

  factory PublicUser.fromJson(Map<String, dynamic> json) {
    return PublicUser(
      id: json['id'],
      fullName: json['full_name'],
      headline: json['headline'],
      avatarUrl: json['avatar_url'],
      location: json['location'],
      about: json['about_text'],
      experiences: (json['experiences'] as List? ?? [])
          .map((e) => PublicExperience.fromJson(e))
          .toList(),
      educations: (json['educations'] as List? ?? [])
          .map((e) => PublicEducation.fromJson(e))
          .toList(),
      skills: List<String>.from(json['skills'] ?? []),
    );
  }
}

class PublicExperience {
  final String title;
  final String company;
  final bool isCurrent;
  final String? description;

  PublicExperience({
    required this.title,
    required this.company,
    required this.isCurrent,
    this.description,
  });

  factory PublicExperience.fromJson(Map<String, dynamic> json) {
    return PublicExperience(
      title: json['title'] ?? '',
      company: json['company_name'] ?? '',
      isCurrent: json['is_current'] ?? false,
      description: json['description'],
    );
  }
}

class PublicEducation {
  final String school;
  final String? degree;
  final String? description;

  PublicEducation({
    required this.school,
    this.degree,
    this.description,
  });

  factory PublicEducation.fromJson(Map<String, dynamic> json) {
    return PublicEducation(
      school: json['school_name'] ?? '',
      degree: json['degree'],
      description: json['description'],
    );
  }
}
