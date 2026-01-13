import 'package:flutter/material.dart';

class FunnelSection extends StatelessWidget {
  final Color textColor;
  final Color subTextColor;
  final Color primary;

  const FunnelSection({
    super.key,
    required this.textColor,
    required this.subTextColor,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final steps = [
      {
        "label": "SEARCH APPEARANCES",
        "value": "15,750",
        "percentage": "100%",
        "color": const Color(0xFF3B82F6),
        "icon": Icons.filter_alt_outlined
      },
      {
        "label": "PROFILE CLICKS",
        "value": "4,340",
        "percentage": "27.5%",
        "color": const Color(0xFF6366F1),
        "icon": Icons.mouse_outlined
      },
      {
        "label": "CONNECTED/FOLLOWED",
        "value": "630",
        "percentage": "14.5%",
        "color": const Color(0xFF8B5CF6),
        "icon": Icons.person_add_outlined
      },
      {
        "label": "MESSAGE/INQUIRY",
        "value": "84",
        "percentage": "13.3%",
        "color": const Color(0xFFD946EF),
        "icon": Icons.chat_bubble_outline
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isDark ? Border.all(color: Colors.white.withValues(alpha: 0.05)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recruiter Funnel", 
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 4),
          const Text(
            "From search to conversation", 
            style: TextStyle(color: Colors.white54, fontSize: 14)
          ),
          const SizedBox(height: 32),
          Column(
            children: steps.map((step) => _funnelItem(
              icon: step["icon"] as IconData,
              label: step["label"] as String,
              value: step["value"] as String,
              percentage: step["percentage"] as String,
              color: step["color"] as Color,
              isDark: isDark,
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _funnelItem({
    required IconData icon,
    required String label,
    required String value,
    required String percentage,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label, 
                  style: const TextStyle(
                    color: Colors.white54, 
                    fontSize: 12, 
                    fontWeight: FontWeight.bold, 
                    letterSpacing: 0.5
                  )
                ),
                const SizedBox(height: 4),
                Text(
                  value, 
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 22, 
                    fontWeight: FontWeight.w900
                  )
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08), 
              borderRadius: BorderRadius.circular(20)
            ),
            child: Text(
              percentage, 
              style: const TextStyle(
                color: Colors.white70, 
                fontSize: 13, 
                fontWeight: FontWeight.w800
              )
            ),
          ),
        ],
      ),
    );
  }
}
