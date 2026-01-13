import 'package:flutter/material.dart';

class AnalyticsTimeRange extends StatelessWidget {
  final String selectedRange;
  final Function(String) onRangeSelected;

  const AnalyticsTimeRange({
    super.key,
    required this.selectedRange,
    required this.onRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    const primary = Color(0xFF6366F1);
    final ranges = ["Last 7 Days", "Last 30 Days", "Last 90 Days", "All Time"];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: ranges.map((range) {
          bool isSelected = selectedRange == range;
          return GestureDetector(
            onTap: () => onRangeSelected(range),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? primary : (isDark ? const Color(0xFF1F2937) : Colors.grey[200]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                range,
                style: TextStyle(
                  color: isSelected ? Colors.white : (isDark ? Colors.white54 : Colors.black54),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
