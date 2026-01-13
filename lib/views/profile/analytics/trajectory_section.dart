import 'package:flutter/material.dart';
import 'analytics_charts.dart';

class TrajectoryData {
  final String role;
  final List<String> labels;
  final List<double> values;
  final List<double> targetValues;
  final double readiness;
  final List<Map<String, dynamic>> focusAreas;

  TrajectoryData({
    required this.role,
    required this.labels,
    required this.values,
    required this.targetValues,
    required this.readiness,
    required this.focusAreas,
  });
}

class TrajectorySection extends StatefulWidget {
  final Color primary;
  final Color textColor;

  const TrajectorySection({
    super.key,
    required this.primary,
    required this.textColor,
  });

  @override
  State<TrajectorySection> createState() => _TrajectorySectionState();
}

class _TrajectorySectionState extends State<TrajectorySection> {
  String selectedRole = "Senior Product Designer";

  final Map<String, TrajectoryData> roleData = {
    "Senior Product Designer": TrajectoryData(
      role: "Senior Product Designer",
      labels: ["UI Design", "UX Rese", "Prototyp", "Design Systems", "Leadership", "Strategy"],
      values: [0.8, 0.7, 0.9, 0.6, 0.5, 0.65],
      targetValues: [0.9, 0.85, 0.85, 0.9, 0.8, 0.85],
      readiness: 0.82,
      focusAreas: [
        {"label": "Leadership", "needed": "+30% needed", "progress": 0.5},
        {"label": "Design Systems", "needed": "+25% needed", "progress": 0.6},
        {"label": "Strategy", "needed": "+20% needed", "progress": 0.65},
      ],
    ),
    "Full Stack Engineer": TrajectoryData(
      role: "Full Stack Engineer",
      labels: ["Frontend", "Backend", "DevOps", "Testing", "System Design", "Architecture"],
      values: [0.9, 0.8, 0.5, 0.7, 0.6, 0.55],
      targetValues: [0.95, 0.9, 0.8, 0.85, 0.85, 0.8],
      readiness: 0.75,
      focusAreas: [
        {"label": "DevOps", "needed": "+30% needed", "progress": 0.5},
        {"label": "Architecture", "needed": "+25% needed", "progress": 0.55},
        {"label": "System Design", "needed": "+25% needed", "progress": 0.6},
      ],
    ),
    "Marketing Manager": TrajectoryData(
      role: "Marketing Manager",
      labels: ["SEO", "Content", "Ads", "Analytics", "Strategy", "Social"],
      values: [0.6, 0.85, 0.7, 0.5, 0.6, 0.9],
      targetValues: [0.85, 0.9, 0.85, 0.8, 0.85, 0.95],
      readiness: 0.68,
      focusAreas: [
        {"label": "Analytics", "needed": "+30% needed", "progress": 0.5},
        {"label": "SEO", "needed": "+25% needed", "progress": 0.6},
        {"label": "Strategy", "needed": "+25% needed", "progress": 0.6},
      ],
    ),
    "Frontend Architect": TrajectoryData(
      role: "Frontend Architect",
      labels: ["React/Next.js", "System Design", "Performance", "Testing", "DevOps", "Mentoring"],
      values: [0.9, 0.7, 0.8, 0.6, 0.5, 0.75],
      targetValues: [0.95, 0.9, 0.9, 0.85, 0.8, 0.9],
      readiness: 0.78,
      focusAreas: [
        {"label": "DevOps", "needed": "+30% needed", "progress": 0.5},
        {"label": "Testing", "needed": "+25% needed", "progress": 0.6},
        {"label": "System Design", "needed": "+20% needed", "progress": 0.7},
      ],
    ),
  };

  @override
  Widget build(BuildContext context) {
    final data = roleData[selectedRole]!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isDark ? Border.all(color: Colors.white.withValues(alpha: 0.05)) : null,
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.track_changes, color: widget.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                "Career Trajectory & Skill Gap",
                style: TextStyle(
                  color: widget.textColor, 
                  fontSize: 18, 
                  fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Compare your current skills against your dream role.",
            style: TextStyle(color: widget.textColor.withValues(alpha: 0.5), fontSize: 14),
          ),
          const SizedBox(height: 24),
          
          // Role Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.textColor.withValues(alpha: 0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedRole,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                icon: Icon(Icons.keyboard_arrow_down, color: widget.textColor.withValues(alpha: 0.5)),
                items: roleData.keys.map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(
                      role, 
                      style: TextStyle(
                        color: widget.textColor, 
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      )
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedRole = value;
                    });
                  }
                },
              ),
            ),
          ),
          
          const SizedBox(height: 48),
          Center(
            child: SizedBox(
              height: 240,
              width: 240,
              child: CustomPaint(
                painter: RadarChartPainter(
                  labels: data.labels,
                  values: data.values,
                  targetValues: data.targetValues,
                  primary: widget.primary,
                  textColor: widget.textColor.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Role Readiness", 
                style: TextStyle(color: widget.textColor.withValues(alpha: 0.5), fontSize: 16, fontWeight: FontWeight.w500)
              ),
              Text(
                "${(data.readiness * 100).toInt()}%", 
                style: TextStyle(color: widget.primary, fontSize: 32, fontWeight: FontWeight.w900)
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: data.readiness,
              backgroundColor: widget.primary.withValues(alpha: 0.1),
              color: widget.primary,
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "You are on track for this role.", 
            style: TextStyle(color: widget.textColor.withValues(alpha: 0.5), fontSize: 13, fontWeight: FontWeight.w500)
          ),
          
          const SizedBox(height: 48),
          Row(
            children: [
              const Icon(Icons.bolt, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                "Priority Focus Areas", 
                style: TextStyle(color: widget.textColor, fontSize: 16, fontWeight: FontWeight.bold)
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...data.focusAreas.map((area) => _skillProgress(
            context, 
            area["label"], 
            area["needed"], 
            area["progress"]
          )),
          
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text("View Recommended Courses", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skillProgress(BuildContext context, String label, String needed, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label, 
                style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w600, fontSize: 14)
              ),
              Text(
                needed, 
                style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w800)
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: widget.textColor.withValues(alpha: 0.05),
              color: Colors.orange,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
