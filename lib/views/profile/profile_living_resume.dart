import 'package:flutter/material.dart';

class ProfileLivingResume extends StatelessWidget {
  final bool isOverviewSelected;
  final Function(bool) onTabChanged;
  final VoidCallback onUploadResume;
  final VoidCallback onDownloadPDF;

  const ProfileLivingResume({
    super.key,
    required this.isOverviewSelected,
    required this.onTabChanged,
    required this.onUploadResume,
    required this.onDownloadPDF,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Living Resume",
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.file_upload_outlined, color: theme.primaryColor),
                    onPressed: onUploadResume,
                    tooltip: 'Upload Resume',
                  ),
                  IconButton(
                    icon: Icon(Icons.picture_as_pdf_outlined, color: theme.primaryColor),
                    onPressed: onDownloadPDF,
                    tooltip: 'Download PDF',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _tabItem(context, "Overview", isOverviewSelected, () => onTabChanged(true)),
              const SizedBox(width: 12),
              _tabItem(context, "Documents", !isOverviewSelected, () => onTabChanged(false)),
            ],
          ),
          const SizedBox(height: 24),
          if (isOverviewSelected) _buildOverview(context) else _buildDocuments(context),
        ],
      ),
    );
  }

  Widget _tabItem(BuildContext context, String title, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.primaryColor : theme.dividerColor,
          ),
        ),
        child: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: isSelected ? colorScheme.onPrimary : theme.textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildOverview(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your profile is your living resume.",
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          "Keep it updated to showcase your latest achievements and skills to recruiters and your network.",
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.share_outlined),
          label: const Text("Share Profile"),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: theme.primaryColor),
            foregroundColor: theme.primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDocuments(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        _documentItem(context, "Resume_Sally_Liang.pdf", "Updated 2 days ago"),
        const SizedBox(height: 16),
        _documentItem(context, "Portfolio_2024.pdf", "Updated 1 month ago"),
      ],
    );
  }

  Widget _documentItem(BuildContext context, String title, String subtitle) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.description_outlined, color: theme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
