import 'package:flutter/material.dart';
import 'account_settings.dart';
import 'privacy_settings.dart';
import 'appearance_settings.dart';
import 'notification_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSettingsGroup(context, "Account", [
            _SettingsTile(
              icon: Icons.person_outline,
              title: "Profile Information",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountSettings())),
            ),
            _SettingsTile(
              icon: Icons.notifications_none,
              title: "Notifications",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettings())),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSettingsGroup(context, "Preferences", [
            _SettingsTile(
              icon: Icons.palette_outlined,
              title: "Appearance",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppearanceSettings())),
            ),
            _SettingsTile(
              icon: Icons.lock_outline,
              title: "Privacy & Security",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacySettings())),
            ),
          ]),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error.withValues(alpha: 0.1),
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
            ),
            child: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.primaryColor),
      title: Text(title, style: theme.textTheme.bodyLarge),
      trailing: Icon(Icons.chevron_right, color: theme.iconTheme.color?.withValues(alpha: 0.3)),
      onTap: onTap,
    );
  }
}
