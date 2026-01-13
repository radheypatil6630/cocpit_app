import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import '../bottom_navigation.dart';
import 'settings_screen/settings_screen.dart';
import 'analytics/analytics_dashboard_screen.dart';
import '../../services/secure_storage.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../login/signin_screen.dart';

import 'profile_models.dart';
import 'profile_header.dart';
import 'profile_info_identity.dart';
import 'profile_stats.dart';
import 'profile_living_resume.dart';
import 'profile_about_section.dart';
import 'profile_experience_section.dart';
import 'profile_education_section.dart';
import 'profile_skills_section.dart';
import 'profile_posts_section.dart';
import 'profile_suggested_section.dart';
import 'profile_modals.dart';
import 'photo_action_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final AuthService authService = AuthService();
  final ProfileService profileService = ProfileService();

  Map<String, dynamic>? profile;
  bool isLoading = true;

  // Profile Data State
  String name = "";
  String headline = "";
  String location = "";
  String about = "";
  
  String openTo = "";
  String availability = "";
  String preference = "";
  String profileImage = 'lib/images/profile.jpg';
  String? coverImage;

  List<Experience> experiences = [];
  List<Education> educations = [];
  List<String> skills = [];

  final List<UserPost> posts = [
    UserPost(
      title: "Just finished a deep dive into data analysis trends for 2024.",
      content: "Just finished a deep dive into data analysis trends for 2024. The shift towards AI-driven forecasting is fascinating! #DataAnalysis #FinTech",
      date: "1d ago",
      likes: 1200,
      comments: 15,
      shares: 8,
      category: "Professional",
    ),
  ];

  final List<Map<String, dynamic>> suggestedUsers = [
    {
      'name': 'Sarah Williams',
      'role': 'UX Designer',
      'followers': '2.3k',
      'profile': 'lib/images/profile3.jpg',
      'isVerified': true,
    },
  ];

  bool isOverviewSelected = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await profileService.getMyProfile();
      if (data == null) return;

      setState(() {
        profile = data;
        final user = data['user'];

        name = user['full_name'] ?? '';
        headline = user['headline'] ?? '';
        location = user['location'] ?? '';
        about = user['about_text'] ?? '';
        profileImage = user['avatar_url'] ?? profileImage;

        openTo = user['open_to'] ?? 'Full-time';
        availability = user['availability'] ?? 'Immediate';
        preference = user['work_preference'] ?? 'Hybrid';

        experiences = (data['experiences'] as List)
            .map((e) => Experience.fromJson(e))
            .toList();

        educations = (data['educations'] as List)
            .map((e) => Education.fromJson(e))
            .toList();

        // 🔥 Normalize skills to list of names for UI
        skills = (data['skills'] as List).map((s) {
          if (s is String) return s;
          if (s is Map) return (s['name'] ?? '').toString();
          return s.toString();
        }).where((s) => s.isNotEmpty).toList();
      });
    } catch (e) {
      debugPrint("❌ Profile load error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSkillsModal() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SkillsModal(initialSkills: profile?['skills'] ?? []),
    );

    if (result == true) {
      await _loadProfile();
    }
  }

  void _showExperienceModal({Experience? experience, int? index}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExperienceModal(experience: experience),
    );

    if (result == true) {
      await _loadProfile();
    }
  }

  void _showEducationModal({Education? education, int? index}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EducationModal(education: education),
    );

    if (result == true) {
      await _loadProfile();
    }
  }

  // ... rest of the methods (edit identity, edit profile, logout, etc)

  void _handleProfilePhotoActions() {
    PhotoActionHelper.showPhotoActions(
      context: context,
      title: "Profile Photo",
      imagePath: profileImage,
      heroTag: 'profile_hero',
      onUpdate: () {},
      onDelete: () => setState(() => profileImage = ''),
    );
  }

  void _handleCoverPhotoActions() {
    PhotoActionHelper.showPhotoActions(
      context: context,
      title: "Cover Photo",
      imagePath: coverImage,
      heroTag: 'cover_hero',
      onUpdate: () {},
      onDelete: () => setState(() => coverImage = null),
    );
  }

  void _showEditIdentityModal() async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditIdentityModal(
        initialOpenTo: openTo,
        initialAvailability: availability,
        initialPreference: preference,
      ),
    );

    if (result != null) {
      setState(() {
        openTo = result['openTo']!;
        availability = result['availability']!;
        preference = result['preference']!;
      });
    }
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          initialData: {
            'name': name,
            'headline': headline,
            'location': location,
            'about': about,
          },
        ),
      ),
    );

    if (result == true) {
      await _loadProfile();
    }
  }

  Future<void> _logout() async {
    try {
      await authService.logout();
    } catch (_) {
      await AppSecureStorage.clearAll();
    }

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      endDrawer: _buildMenuDrawer(theme),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 4),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeader(
                user: profile!['user'],
                profileImage: profileImage,
                coverImage: coverImage,
                onMenuPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                onCameraPressed: _handleProfilePhotoActions,
                onCoverCameraPressed: _handleCoverPhotoActions,
                backgroundColor: theme.scaffoldBackgroundColor,
              ),
              const SizedBox(height: 80),
              ProfileInfoIdentity(
                name: name,
                headline: headline,
                location: location,
                openTo: openTo,
                availability: availability,
                preference: preference,
                onEditProfile: _navigateToEditProfile,
                onEditIdentity: _showEditIdentityModal,
              ),
              _buildDivider(theme),
              const ProfileStats(),
              _buildDivider(theme),
              ProfileLivingResume(
                isOverviewSelected: isOverviewSelected,
                onTabChanged: (selected) => setState(() => isOverviewSelected = selected),
                onUploadResume: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const UploadResumeModal(),
                  );
                },
                onDownloadPDF: () {},
              ),
              _buildDivider(theme),
              ProfileAboutSection(about: about),
              _buildDivider(theme),
              ProfileExperienceSection(
                experiences: experiences,
                onAddEditExperience: _showExperienceModal,
              ),
              _buildDivider(theme),
              ProfileEducationSection(
                educations: educations,
                onAddEditEducation: _showEducationModal,
              ),
              _buildDivider(theme),
              ProfileSkillsSection(
                skills: skills,
                onAddSkill: _showSkillsModal,
              ),
              _buildDivider(theme),
              ProfileLatestPostsSection(
                posts: posts,
                userName: name,
                onSeeAllPosts: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AllPostsScreen(posts: posts, userName: name),
                  ),
                ),
              ),
              _buildDivider(theme),
              ProfileSuggestedSection(suggestedUsers: suggestedUsers),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuDrawer(ThemeData theme) {
    return Drawer(
      width: 200,
      backgroundColor: theme.colorScheme.surface.withOpacity(0.95),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildDrawerItem(theme, Icons.settings_outlined, "Settings", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            }),
            _buildDrawerItem(theme, Icons.analytics_outlined, "Analytics", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsDashboardScreen()));
            }),
            _buildDrawerItem(theme, Icons.logout, "Log out", _logout),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(ThemeData theme, IconData? icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: icon != null ? Icon(icon, color: theme.iconTheme.color, size: 20) : null,
      title: Text(title, style: theme.textTheme.bodyLarge),
      onTap: onTap,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Divider(color: theme.dividerColor, thickness: 1, height: 80),
    );
  }
}
