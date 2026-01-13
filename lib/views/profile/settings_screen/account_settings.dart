import 'package:flutter/material.dart';

class AccountSettings extends StatelessWidget {
  const AccountSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Account Settings"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAccountItem(context, "Personal Info", "Name, email, and phone number", Icons.person_outline),
              const SizedBox(height: 12),
              _buildAccountItem(context, "Password", "Change your account password", Icons.lock_outline),
              const SizedBox(height: 12),
              _buildAccountItem(context, "Language", "English (US)", Icons.language),
              const SizedBox(height: 12),
              _buildAccountItem(context, "Delete Account", "Permanently remove your data", Icons.delete_outline, isDanger: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountItem(BuildContext context, String title, String subtitle, IconData icon, {bool isDanger = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDanger ? colorScheme.error : theme.primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: isDanger ? colorScheme.error : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: theme.iconTheme.color?.withValues(alpha: 0.3), size: 14),
        ],
      ),
    );
  }
}
