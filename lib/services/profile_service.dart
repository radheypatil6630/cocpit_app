import 'dart:convert';
import 'package:cocpit_app/services/api_client.dart';

class ProfileService {

  /// =========================
  /// 🔐 GET LOGGED-IN PROFILE
  /// =========================
  Future<Map<String, dynamic>?> getMyProfile() async {
    final response = await ApiClient.get("/profile/me");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  /// =========================
  /// 🔍 GET ANY USER PROFILE
  /// =========================
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await ApiClient.get("/users/$userId");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// =========================
  /// 🧑‍💼 EXPERIENCE
  /// =========================

  /// ➕ ADD EXPERIENCE
  Future<bool> addExperience({
    required String title,
    required String company,
    required String location,
    required String startDate,
    String? endDate,
    required bool currentlyWorking,
    required String description,
  }) async {
    final response = await ApiClient.post(
      "/profile/experiences",
      body: {
        "title": title.trim(),
        "company_name": company.trim(),
        "location": location.trim(),
        "start_date": startDate,
        "end_date": currentlyWorking ? null : endDate,
        "is_current": currentlyWorking,
        "description": description.trim(),
      },
    );

    return response.statusCode == 201;
  }

  /// 🔄 UPDATE EXPERIENCE
  Future<bool> updateExperience({
    required String id,
    required String title,
    required String company,
    required String location,
    required String startDate,
    String? endDate,
    required bool isCurrent,
    required String description,
  }) async {
    final response = await ApiClient.put(
      "/profile/experiences/$id",
      body: {
        "title": title.trim(),
        "company_name": company.trim(),
        "location": location.trim(),
        "start_date": startDate,
        "end_date": isCurrent ? null : endDate,
        "is_current": isCurrent,
        "description": description.trim(),
      },
    );

    return response.statusCode == 200;
  }

  /// 🗑️ DELETE EXPERIENCE
  Future<bool> deleteExperience(String id) async {
    final response = await ApiClient.delete(
      "/profile/experiences/$id",
    );

    return response.statusCode == 200;
  }

  /// =========================
  /// 🎓 EDUCATION
  /// =========================

  /// ➕ ADD EDUCATION
  Future<bool> addEducation({
    required String school,
    required String degree,
    required String fieldOfStudy,
    required String startDate,
    String? endDate,
    required String description,
  }) async {
    final response = await ApiClient.post(
      "/profile/educations",
      body: {
        "school_name": school.trim(),
        "degree": degree.trim(),
        "field_of_study": fieldOfStudy.trim(),
        "start_date": startDate,
        "end_date": endDate,
        "description": description.trim(),
      },
    );

    return response.statusCode == 201;
  }

  /// 🔄 UPDATE EDUCATION
  Future<bool> updateEducation({
    required String id,
    required String school,
    required String degree,
    required String fieldOfStudy,
    required String startDate,
    String? endDate,
    required String description,
  }) async {
    final response = await ApiClient.put(
      "/profile/educations/$id",
      body: {
        "school_name": school.trim(),
        "degree": degree.trim(),
        "field_of_study": fieldOfStudy.trim(),
        "start_date": startDate,
        "end_date": endDate,
        "description": description.trim(),
      },
    );

    return response.statusCode == 200;
  }

  /// 🗑️ DELETE EDUCATION
  Future<bool> deleteEducation(String id) async {
    final response = await ApiClient.delete(
      "/profile/educations/$id",
    );

    return response.statusCode == 200;
  }

  /// =========================
  /// 🧠 SKILLS  ✅ FIXED
  /// =========================

  /// ➕ ADD SKILL
  /// Backend expects: { "name": "React" }
  Future<bool> addSkill(String name) async {
    final response = await ApiClient.post(
      "/profile/skills",
      body: {
        "name": name.trim(),
      },
    );

    return response.statusCode == 201;
  }

  /// 🗑️ DELETE SKILL
  Future<bool> deleteSkill(String skillId) async {
    final response = await ApiClient.delete(
      "/profile/skills/$skillId",
    );

    return response.statusCode == 200;
  }
}
