import 'package:flutter/material.dart';
import 'analytics_charts.dart';

class EngagementSection extends StatefulWidget {
  final Color primary;
  final Color textColor;
  final String selectedRange;

  const EngagementSection({
    super.key,
    required this.primary,
    required this.textColor,
    required this.selectedRange,
  });

  @override
  State<EngagementSection> createState() => _EngagementSectionState();
}

class _EngagementSectionState extends State<EngagementSection> {
  int? selectedIndex;

  // Mock data for different ranges
  final Map<String, Map<String, dynamic>> chartData = {
    "Last 7 Days": {
      "interactions": [15.0, 18.0, 14.0, 22.0, 19.0, 25.0, 23.0],
      "views": [105.0, 125.0, 115.0, 145.0, 135.0, 160.0, 155.0],
      "labels": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
    },
    "Last 30 Days": {
      "interactions": [15.0, 17.0, 18.0, 16.0, 20.0, 22.0, 19.0, 21.0, 23.0, 18.0, 20.0, 25.0, 22.0, 24.0, 26.0, 21.0, 23.0, 22.0, 25.0, 27.0, 24.0, 26.0, 25.0, 23.0, 25.0, 24.0, 26.0, 27.0, 28.0, 26.0],
      "views": [100.0, 110.0, 120.0, 115.0, 130.0, 140.0, 135.0, 145.0, 150.0, 140.0, 130.0, 150.0, 160.0, 145.0, 135.0, 160.0, 175.0, 150.0, 165.0, 170.0, 155.0, 160.0, 155.0, 170.0, 175.0, 165.0, 175.0, 178.0, 180.0, 182.0],
      "labels": ["Dec 1", "Dec 8", "Dec 16", "Dec 24", "Jan 1"],
    },
    "Last 90 Days": {
      "interactions": List.generate(90, (i) => 15.0 + (i * 0.1) + (i % 5)),
      "views": List.generate(90, (i) => 100.0 + (i * 0.5) + (i % 10)),
      "labels": ["Oct", "Nov", "Dec", "Jan"],
    },
    "All Time": {
      "interactions": List.generate(12, (i) => 200.0 + (i * 20)),
      "views": List.generate(12, (i) => 1500.0 + (i * 100)),
      "labels": ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
    },
  };

  @override
  Widget build(BuildContext context) {
    final data = chartData[widget.selectedRange] ?? chartData["Last 30 Days"]!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
            "Engagement Overview", 
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 4),
          const Text(
            "Profile interactions over time", 
            style: TextStyle(color: Colors.white54, fontSize: 14)
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _chartLegend(Colors.tealAccent, "Interactions"),
              const SizedBox(width: 16),
              _chartLegend(widget.primary, "Profile Views"),
            ],
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    final chartWidth = constraints.maxWidth;
                    final x = details.localPosition.dx;
                    if (x >= 0 && x <= chartWidth) {
                      selectedIndex = (x / chartWidth * (data["interactions"]!.length - 1)).round();
                    }
                  });
                },
                onPanEnd: (_) => setState(() => selectedIndex = null),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: LineChartPainter(
                          interactions: (data["interactions"] as List).cast<double>(),
                          profileViews: (data["views"] as List).cast<double>(),
                          primary: widget.primary,
                          accent: Colors.tealAccent,
                          textColor: Colors.white24,
                          selectedIndex: selectedIndex,
                        ),
                      ),
                    ),
                    if (selectedIndex != null)
                      Positioned(
                        left: (selectedIndex! / (data["interactions"]!.length - 1)) * constraints.maxWidth - 50,
                        top: 0,
                        child: _buildTooltip(data),
                      ),
                  ],
                ),
              );
            }
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: (data["labels"] as List<String>).map((label) => Text(
              label, 
              style: const TextStyle(color: Colors.white38, fontSize: 12)
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTooltip(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Dec", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text("Interactions : ", style: TextStyle(color: Colors.tealAccent, fontSize: 12)),
              Text("${(data["interactions"] as List)[selectedIndex!].toInt()}", style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text("Profile Views : ", style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
              Text("${(data["views"] as List)[selectedIndex!].toInt()}", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chartLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}
