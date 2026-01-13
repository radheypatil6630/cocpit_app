class ApiConfig {
  // ======================
  // ENVIRONMENT SETTINGS
  // ======================

  static const String protocol = "http";
  static const String host = "192.168.1.2"; // Node backend IP
  static const String port = "5000";

  static const String baseUrl = "$protocol://$host:$port/api";

  // ======================
  // AUTH ENDPOINTS
  // ======================

  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/auth/register";
  static const String refresh = "$baseUrl/auth/refresh";
  static const String logout = "$baseUrl/auth/logout";
  static const String me = "$baseUrl/auth/me";
  static const String searchUsers = "$baseUrl/users/search";
  static const String getPublicProfile = "$baseUrl/users";
}
