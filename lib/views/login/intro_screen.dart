import 'package:flutter/material.dart';
import 'signin_screen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF7C3AED),
              Color(0xFF6D28D9),
              Color(0xFF5B21B6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              _title(),
              const SizedBox(height: 18),
              _subtitle(),
              const Spacer(),
              _illustration(),
              const Spacer(),
              _indicators(),
              const SizedBox(height: 16),
              _countText(),
              const SizedBox(height: 30),
              _continueButton(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _title() {
    return const Text(
      "Connect. Grow.\nSucceed.",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.2,
      ),
    );
  }

  Widget _subtitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 26),
      child: Text(
        "Where professionals meet opportunities. Build meaningful connections that accelerate your career.",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: Colors.white70,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _illustration() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _person(Colors.cyan),
        const SizedBox(width: 10),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 10),
        _person(Colors.redAccent),
      ],
    );
  }

  Widget _person(Color color) {
    return Column(
      children: [
        CircleAvatar(radius: 18, backgroundColor: color),
        const SizedBox(height: 6),
        Container(
          width: 26,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _indicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
            (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: index == 0 ? Colors.white : Colors.white38,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _countText() {
    return const Text(
      "10k+ professionals",
      style: TextStyle(color: Colors.white70),
    );
  }

  Widget _continueButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: SizedBox(
        width: double.infinity,
        height: 46,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SignInScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            "Get Started",
            style: TextStyle(
              color: Color(0xFF5B21B6),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
