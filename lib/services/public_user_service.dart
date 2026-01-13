import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/public_user.dart';
import 'secure_storage.dart';

class PublicUserService {
  static Future<PublicUser> getUserProfile(String userId) async {
    final token = await AppSecureStorage.getAccessToken();

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/users/$userId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return PublicUser.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load public profile");
    }
  }
}
