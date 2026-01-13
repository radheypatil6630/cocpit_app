import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/theme_service.dart';

class AppearanceSettings extends StatelessWidget {
  const AppearanceSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeService = Provider.of<ThemeService>(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Appearance"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildGroup(context, "Theme", [
            _ThemeOption(
              theme: AppTheme.light,
              title: "Light Mode",
              subtitle: "Clean and bright interface",
              icon: Icons.light_mode_outlined,
              isSelected: themeService.currentTheme == AppTheme.light,
              onTap: () => themeService.setTheme(AppTheme.light),
            ),
            _ThemeOption(
              theme: AppTheme.dark,
              title: "Dark Mode",
              subtitle: "Classic dark experience",
              icon: Icons.nightlight_outlined,
              isSelected: themeService.currentTheme == AppTheme.dark,
              onTap: () => themeService.setTheme(AppTheme.dark),
            ),
            _ThemeOption(
              theme: AppTheme.navy,
              title: "Navy Mode",
              subtitle: "Premium deep blue look",
              icon: Icons.bolt,
              isSelected: themeService.currentTheme == AppTheme.navy,
              onTap: () => themeService.setTheme(AppTheme.navy),
            ),
            _ThemeOption(
              theme: AppTheme.system,
              title: "System Default",
              subtitle: "Follow device settings",
              icon: Icons.settings_suggest_outlined,
              isSelected: themeService.currentTheme == AppTheme.system,
              onTap: () => themeService.setTheme(AppTheme.system),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildGroup(BuildContext context, String title, List<Widget> children) {
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

class _ThemeOption extends StatelessWidget {
  final AppTheme theme;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isSelected ? appTheme.primaryColor : appTheme.iconTheme.color),
      title: Text(title, style: appTheme.textTheme.bodyLarge),
      subtitle: Text(subtitle, style: appTheme.textTheme.bodySmall),
      trailing: isSelected 
        ? Icon(Icons.check_circle, color: appTheme.primaryColor) 
        : Icon(Icons.radio_button_off, color: appTheme.dividerColor),
    );
  }
}
