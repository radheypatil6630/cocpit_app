import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'services/secure_storage.dart';
import 'views/feed/home_screen.dart';
import 'views/login/signin_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await AppSecureStorage.getAccessToken();

    if (token == null) {
      _goToLogin();
      return;
    }

    final me = await authService.getMe();

    if (me != null) {
      _goToHome();
      return;
    }

    final refreshed = await authService.refreshAccessToken();
    if (refreshed != null) {
      _goToHome();
    } else {
      _goToLogin();
    }
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
