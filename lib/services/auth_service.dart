import 'dart:convert';

import 'package:cocpit_app/services/api_client.dart';
import 'package:cocpit_app/services/secure_storage.dart';

class AuthService {
  static const String baseUrl = "http://192.168.1.2:5000/api";

  /// ================= REGISTER =================
  /// Website behavior:
  /// - Creates user
  /// - DOES NOT create session
  /// - User must login after signup
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String accountType,
  }) async {
    final response = await ApiClient.post(
      "/auth/register",
      body: {
        "fullName": fullName,
        "email": email.toLowerCase().trim(),
        "password": password,
        "accountType": accountType,
      },
    );

    return response.statusCode == 201;
  }

  /// ================= LOGIN =================
  /// Website behavior:
  /// - Creates session
  /// - Stores refresh token in DB
  /// - Returns access + refresh tokens
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      "/auth/login",
      body: {
        "email": email.toLowerCase().trim(),
        "password": password,
      },
    );

    if (response.statusCode != 200) return false;

    final body = jsonDecode(response.body);

    await AppSecureStorage.saveAccessToken(body["accessToken"]);
    await AppSecureStorage.saveRefreshToken(body["refreshToken"]);

    // Save initial user (will be refreshed by /auth/me)
    if (body["user"] != null) {
      await AppSecureStorage.saveUser(jsonEncode(body["user"]));
    }

    return true;
  }

  /// ================= GET CURRENT USER =================
  /// Single source of truth for user data
  /// Used on:
  /// - App startup
  /// - After login
  /// - Profile refresh
  Future<Map<String, dynamic>?> getMe() async {
    final response = await ApiClient.get("/auth/me");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // 🔥 Always sync latest backend user
      await AppSecureStorage.saveUser(jsonEncode(data));

      return data;
    }

    return null;
  }

  /// ================= REFRESH ACCESS TOKEN =================
  /// Called automatically by ApiClient on 401
  Future<String?> refreshAccessToken() async {
    final refreshToken = await AppSecureStorage.getRefreshToken();
    if (refreshToken == null) return null;

    final response = await ApiClient.post(
      "/auth/refresh",
      body: {
        "refreshToken": refreshToken,
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final newAccessToken = body["accessToken"];

      await AppSecureStorage.saveAccessToken(newAccessToken);
      return newAccessToken;
    }

    // ❌ Refresh failed → session invalid
    await logout();
    return null;
  }

  /// ================= LOGOUT =================
  /// Website behavior:
  /// - Requires access token
  /// - Deletes refresh token row from DB
  /// - Clears cookies (web)
  /// App behavior:
  /// - Same backend call
  /// - Clear secure storage
  Future<void> logout() async {
    try {
      await ApiClient.post("/auth/logout");
    } catch (_) {
      // Even if backend fails, we still logout locally
    }

    await AppSecureStorage.clearAll();
  }
}
