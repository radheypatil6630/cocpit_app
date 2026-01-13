import 'dart:convert';
import 'package:http/http.dart' as http;

import 'auth_service.dart';
import 'secure_storage.dart';

class ApiClient {
  static const String baseUrl = "http://192.168.1.2:5000/api";

  /// ===================== GET =====================
  static Future<http.Response> get(String path) async {
    return _send(
          (headers) => http.get(
        Uri.parse("$baseUrl$path"),
        headers: headers,
      ),
    );
  }

  /// ===================== POST =====================
  static Future<http.Response> post(
      String path, {
        Map<String, dynamic>? body,
      }) async {
    return _send(
          (headers) => http.post(
        Uri.parse("$baseUrl$path"),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  /// ===================== PUT =====================
  static Future<http.Response> put(
      String path, {
        Map<String, dynamic>? body,
      }) async {
    return _send(
          (headers) => http.put(
        Uri.parse("$baseUrl$path"),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  /// ===================== DELETE =====================
  static Future<http.Response> delete(String path) async {
    return _send(
          (headers) => http.delete(
        Uri.parse("$baseUrl$path"),
        headers: headers,
      ),
    );
  }

  /// =================================================
  /// 🔐 CORE REQUEST HANDLER (AUTO REFRESH ON 401)
  /// =================================================
  static Future<http.Response> _send(
      Future<http.Response> Function(Map<String, String> headers) request,
      ) async {
    final accessToken = await AppSecureStorage.getAccessToken();

    final headers = {
      "Content-Type": "application/json",
      if (accessToken != null && accessToken.isNotEmpty)
        "Authorization": "Bearer $accessToken",
    };

    http.Response response = await request(headers);

    // 🔁 Access token expired → refresh once
    if (response.statusCode == 401) {
      final newToken = await AuthService().refreshAccessToken();

      if (newToken != null) {
        final retryHeaders = {
          ...headers,
          "Authorization": "Bearer $newToken",
        };

        response = await request(retryHeaders);
      }
    }

    return response;
  }
}





/*home
import 'package:flutter/material.dart';
import 'dart:async';

import '../../models/search_user.dart';
import '../../services/user_search_service.dart';
import '../../services/secure_storage.dart';
import '../profile/profile_screen.dart';


import 'chat_screen.dart';
import 'notification_screen.dart';
import '../bottom_navigation.dart';
import 'create_career_moment_screen.dart';
import 'career_moment_viewer.dart';
import '../../widgets/app_top_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showTop = false;
  final TextEditingController _searchController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  // 🔽 BACKEND SEARCH STATE
  List<SearchUser> _searchResults = [];
  Timer? _debounce;

  final List<Map<String, dynamic>> careerMoments = [
    {
      'name': 'You',
      'isMine': true,
      'stories': [
        {'image': 'lib/images/profile.png', 'text': 'Just sharing my latest update with my close friends!', 'time': '1m ago'},
      ],
      'profile': 'lib/images/profile.png',
      'image': 'lib/images/profile.png',
    },
    {
      'name': 'Mike Torres',
      'isMine': false,
      'image': 'lib/images/story1.png',
      'profile': 'lib/images/profile2.jpg',
      'stories': [
        {
          'image': 'lib/images/story1.png',
          'text': 'Excited to share a sneak peek of our latest product feature!',
          'time': '6h ago'
        },
      ],
    },
    {
      'name': 'James Wilson',
      'isMine': false,
      'image': 'lib/images/story4.png',
      'profile': 'lib/images/profile3.jpg',
      'stories': [
        {
          'image': 'lib/images/story4.png',
          'text': 'Sharing some insights from our latest data analysis project.',
          'time': '8h ago'
        },
      ],
    },
  ];

  final List<Map<String, dynamic>> _posts = [
    {
      'id': '1',
      'name': 'Sarah Chen',
      'title': 'UX Designer at Design Studio',
      'time': '2h ago',
      'text': "🎨 Just launched our new design system! Working with an amazing team to create consistent, accessible experiences across all our products.",
      'image': 'lib/images/post1.jpg',
      'profile': 'lib/images/profile3.jpg',
      'likes': 234,
      'isLiked': false,
      'isPrivate': false,
      'comments_count': 47,
      'shares': 12,
      'comments': [
        {
          'name': 'Alex Johnson',
          'time': '2h',
          'text': 'This looks amazing! Can\'t wait to see it in action.',
          'likes': 15,
          'isLiked': false,
        },
        {
          'name': 'Maria Garcia',
          'time': '1h',
          'text': 'Great work, Maria! The component library is so clean.',
          'likes': 8,
          'isLiked': false,
        }
      ],
    },
    {
      'id': '2',
      'name': 'Sally Liang',
      'title': 'Senior Financial Analyst',
      'time': '1d ago',
      'text': "Just finished a deep dive into data analysis trends for 2024. The shift towards AI-driven forecasting is fascinating!",
      'image': null,
      'profile': 'lib/images/profile4.jpg',
      'likes': 1200,
      'isLiked': false,
      'isPrivate': false,
      'comments_count': 15,
      'shares': 8,
      'comments': [],
    },
    {
      'id': 'suggested',
      'type': 'suggested',
    },
    {
      'id': '3',
      'name': 'Sally Liang',
      'title': 'Senior Financial Analyst at Johnson & Johnson',
      'time': '3d ago',
      'text': "Great session on Product Strategy today. Always learning! 📚",
      'image': null,
      'profile': 'lib/images/profile4.jpg',
      'likes': 850,
      'isLiked': false,
      'isPrivate': false,
      'comments_count': 12,
      'shares': 3,
      'comments': [],
    },
    {
      'id': '4',
      'name': 'Sally Liang',
      'title': 'Senior Financial Analyst at Johnson & Johnson',
      'time': '1w ago',
      'text': "Honored to be recognized as Top Contributor of the Month! 🏆 Thanks to my amazing team.",
      'image': null,
      'profile': 'lib/images/profile4.jpg',
      'likes': 2100,
      'isLiked': false,
      'isPrivate': true,
      'comments_count': 45,
      'shares': 12,
      'comments': [],
    },
    {
      'id': '5',
      'name': 'John Smith',
      'title': 'Senior Software Engineer at Meta',
      'time': '5h ago',
      'text': "Great discussions at today’s architecture review 🚀",
      'image': 'lib/images/post2.jpg',
      'profile': 'lib/images/profile2.jpg',
      'likes': 189,
      'isLiked': false,
      'isPrivate': false,
      'comments_count': 23,
      'shares': 8,
      'comments': [],
    },
  ];

  final List<Map<String, dynamic>> suggestedUsers = [
    {
      'name': 'Sarah Williams',
      'role': 'UX Designer',
      'followers': '2.3k',
      'profile': 'lib/images/profile3.jpg',
      'isVerified': true,
    },
    {
      'name': 'Michael Jordan',
      'role': 'Software Engineer',
      'followers': '1.8k',
      'profile': 'lib/images/profile2.jpg',
      'isVerified': false,
    },
    {
      'name': 'Alex Johnson',
      'role': 'Product Manager',
      'followers': '3.5k',
      'profile': 'lib/images/profile4.jpg',
      'isVerified': true,
    },
  ];

  final List<Map<String, dynamic>> shareToUsers = [
    {'name': 'Michael Chen', 'role': 'Recruiter', 'profile': 'lib/images/profile2.jpg', 'color': Colors.lightBlue},
    {'name': 'Emily Rodriguez', 'role': 'Hiring Manager', 'profile': 'lib/images/profile4.jpg', 'color': Colors.pinkAccent},
    {'name': 'David Park', 'role': 'Connection', 'profile': 'lib/images/profile3.jpg', 'color': Colors.deepPurpleAccent},
    {'name': 'Jessica Williams', 'role': 'Talent Acquisition', 'profile': 'lib/images/profile4.jpg', 'color': Colors.greenAccent},
    {'name': 'Alex Thompson', 'role': 'Designer', 'profile': 'lib/images/profile2.jpg', 'color': Colors.orangeAccent},
  ];

  List<Map<String, dynamic>> get _allPeople {
    return [
      {'name': 'Sarah Chen', 'role': 'UX Designer at Design Studio', 'profile': 'lib/images/profile3.jpg', 'mutual': '5 mutual connections'},
      {'name': 'Michael Chen', 'role': 'Recruiter', 'profile': 'lib/images/profile2.jpg', 'mutual': '12 mutual connections'},
      {'name': 'Emily Rodriguez', 'role': 'Hiring Manager', 'profile': 'lib/images/profile4.jpg', 'mutual': '3 mutual connections'},
      {'name': 'Mike Torres', 'role': 'Product Manager', 'profile': 'lib/images/profile2.jpg', 'mutual': '8 mutual connections'},
      {'name': 'James Wilson', 'role': 'Software Engineer', 'profile': 'lib/images/profile3.jpg', 'mutual': '2 mutual connections'},
    ];
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (query.trim().isEmpty) {
        _overlayEntry?.remove();
        _overlayEntry = null;
        return;
      }

      try {
        final token = await AppSecureStorage.getAccessToken();
        if (token == null) return;

        final results = await UserSearchService.searchUsers(
          query: query,
          token: token,
        );

        _searchResults = results;
        _showBackendOverlay();
      } catch (e) {
        debugPrint("Search error: $e");
      }
    });
  }

  void _showBackendOverlay() {
    _overlayEntry?.remove();

    if (_searchResults.isEmpty) return;

    _overlayEntry = _createBackendOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _createBackendOverlayEntry() {
    final theme = Theme.of(context);

    return OverlayEntry(
      builder: (context) => Positioned(
        width: 300,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: const Offset(0, 50),
          showWhenUnlinked: false,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            color: theme.colorScheme.surface,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _searchResults.take(5).map((user) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : const AssetImage('lib/images/profile.png')
                            as ImageProvider,
                  ),
                  title: Text(user.fullName),
                  subtitle: Text(
                    user.headline ?? user.accountType ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    _searchController.clear();
                    _overlayEntry?.remove();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(userId: user.id),
                      ),
                    );

                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _updateOverlay(String query) {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }

    if (query.isEmpty) return;

    final results = _allPeople.where((p) => p['name'].toString().toLowerCase().contains(query.toLowerCase())).toList();

    if (results.isEmpty) return;

    _overlayEntry = _createOverlayEntry(results);
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry(List<Map<String, dynamic>> results) {
    final theme = Theme.of(context);
    return OverlayEntry(
      builder: (context) => Positioned(
        width: 300,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 50),
          child: Material(
            elevation: 8,
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      "PEOPLE",
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                  ),
                  ...results.take(3).map((person) => InkWell(
                    onTap: () {
                      _searchController.clear();
                      _updateOverlay("");
                      FocusScope.of(context).unfocus();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage(person['profile']),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(person['name'], style: theme.textTheme.titleSmall),
                                Text(person['role'], style: theme.textTheme.bodySmall),
                                Text(person['mutual'], style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _overlayEntry?.remove();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppTopBar(
        searchType: SearchType.feed,
        controller: _searchController,
        onChanged: _onSearchChanged,
        layerLink: _layerLink,
      ),
      body: ListView(
        children: [
          _storiesHeader(theme),
          _careerMomentsBar(theme),
          const SizedBox(height: 20),
          _topRecentToggle(theme),
          Divider(color: theme.dividerColor, height: 1),
          ..._posts.map((post) {
            if (post['type'] == 'suggested') {
              return _suggestedForYouSection(theme);
            }
            return _postView(post, theme);
          }),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
    );
  }

  Widget _storiesHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Stories", style: theme.textTheme.titleLarge),
          Text("View All", style: TextStyle(color: theme.primaryColor, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _careerMomentsBar(ThemeData theme) {
    double screenWidth = MediaQuery.of(context).size.width;
    double itemWidth = screenWidth > 600 ? 150 : 120;

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: careerMoments.length,
        itemBuilder: (context, index) {
          final m = careerMoments[index];
          return GestureDetector(
            onTap: () {
              if (m['isMine']) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateCareerMomentScreen()));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => CareerMomentViewer(users: careerMoments, initialUserIndex: index)));
              }
            },
            child: Container(
              width: itemWidth,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: !m['isMine'] ? DecorationImage(image: AssetImage(m['image']), fit: BoxFit.cover) : null,
                color: m['isMine'] ? theme.primaryColor : theme.cardColor,
              ),
              child: Stack(
                children: [
                  if (m['isMine'])
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: theme.colorScheme.onPrimary.withValues(alpha: 0.2), shape: BoxShape.circle),
                            child: Icon(Icons.add, color: theme.colorScheme.onPrimary, size: 30),
                          ),
                          const SizedBox(height: 12),
                          Text("Your Update", style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  if (!m['isMine'])
                    Positioned(
                      bottom: 8, left: 0, right: 0,
                      child: Column(
                        children: [
                          CircleAvatar(radius: 18, backgroundColor: theme.primaryColor, child: CircleAvatar(radius: 16, backgroundImage: AssetImage(m['profile']))),
                          const SizedBox(height: 4),
                          Text(m['name'], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _topRecentToggle(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _togglePill("Top", showTop, theme, () => setState(() => showTop = true)),
          const SizedBox(width: 12),
          _togglePill("Recent", !showTop, theme, () => setState(() => showTop = false)),
        ],
      ),
    );
  }

  Widget _togglePill(String text, bool selected, ThemeData theme, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(color: selected ? theme.primaryColor : Colors.transparent, borderRadius: BorderRadius.circular(10)),
        child: Text(text, style: TextStyle(color: selected ? theme.colorScheme.onPrimary : theme.textTheme.bodyMedium?.color, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _suggestedForYouSection(ThemeData theme) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth > 600 ? 250 : 180;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text("Suggested for you", style: theme.textTheme.titleLarge),
        ),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: suggestedUsers.length,
            itemBuilder: (context, index) {
              final user = suggestedUsers[index];
              return Container(
                width: cardWidth,
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(radius: 40, backgroundImage: AssetImage(user['profile'])),
                        if (user['isVerified'])
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: theme.primaryColor,
                              child: Icon(Icons.check, color: theme.colorScheme.onPrimary, size: 12),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(user['name'], style: theme.textTheme.titleSmall, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(user['role'], style: theme.textTheme.bodySmall, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text("${user['followers']} followers", style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: theme.colorScheme.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text("Follow", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _postView(Map<String, dynamic> post, ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 24, backgroundImage: AssetImage(post['profile'])),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(post['name'], style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                            if (post['isPrivate']) ...[
                              const SizedBox(width: 4),
                              Icon(Icons.lock, size: 12, color: theme.textTheme.bodySmall?.color),
                            ],
                          ],
                        ),
                        Text(post['title'], style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(post['time'], style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
                ],
              ),
              const SizedBox(height: 12),
              Text(post['text'], style: theme.textTheme.bodyMedium),
              if (post['image'] != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(post['image'], fit: BoxFit.cover, width: double.infinity, height: 200),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  _postAction(Icons.favorite_border, post['likes'].toString(), theme),
                  const SizedBox(width: 20),
                  _postAction(Icons.chat_bubble_outline, post['comments_count'].toString(), theme),
                  const SizedBox(width: 20),
                  _postAction(Icons.share_outlined, post['shares'].toString(), theme),
                  const Spacer(),
                  Icon(Icons.bookmark_border, color: theme.iconTheme.color?.withValues(alpha: 0.6)),
                ],
              ),
            ],
          ),
        ),
        Divider(color: theme.dividerColor, height: 1),
      ],
    );
  }

  Widget _postAction(IconData icon, String count, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.iconTheme.color?.withValues(alpha: 0.6)),
        const SizedBox(width: 6),
        Text(count, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
*/




/*profile
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
  final String userId;

  const ProfileScreen({
    super.key,
    required this.userId,
  });

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
  String name = "Sally Liang";
  String headline = "Senior Financial Analyst at Johnson & Johnson";
  String jobTitle = "Senior Financial Analyst";
  String company = "Johnson & Johnson";
  String school = "Stanford University";
  String degree = "MBA in Business Administration";
  String location = "Berkeley, California, United States";
  String about = "Passionate product manager with 7+ years of experience building user-centric solutions that drive business growth. Proven track record in agile development, user research, and cross-functional team leadership. Successfully launched 15+ features that improved user engagement by 40% and increased revenue by \$2M annually.";

  String openTo = "Full-time";
  String availability = "Immediate";
  String preference = "Hybrid";
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
      // ✅ Using widget.userId to call backend
      final data = await profileService.getUserProfile(widget.userId);
      if (data == null) return;

      setState(() {
        profile = data;

        final user = data['user'];

        // 🔥 HEADER DATA (FROM DB)
        name = user['full_name'] ?? '';
        headline = user['headline'] ?? '';
        location = user['location'] ?? '';
        about = user['about_text'] ?? '';

        profileImage = user['avatar_url'] ?? profileImage;

        // 🔥 PROFILE META
        openTo = user['open_to'] ?? '';
        availability = user['availability'] ?? '';
        preference = user['work_preference'] ?? '';

        // 🔥 EXPERIENCES
        experiences = (data['experiences'] as List)
            .map((e) => Experience.fromJson(e))
            .toList();

        // 🔥 EDUCATIONS
        educations = (data['educations'] as List)
            .map((e) => Education.fromJson(e))
            .toList();

        // 🔥 SKILLS
        skills = (data['skills'] as List)
            .map((s) => s.toString())
            .toList();
      });
    } catch (e) {
      debugPrint("❌ Profile load error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

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
            'jobTitle': jobTitle,
            'company': company,
            'school': school,
            'degree': degree,
            'location': location,
            'about': about,
          },
        ),
      ),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        name = result['name'] ?? name;
        headline = result['headline'] ?? headline;
        jobTitle = result['jobTitle'] ?? jobTitle;
        company = result['company'] ?? company;
        school = result['school'] ?? school;
        degree = result['degree'] ?? degree;
        location = result['location'] ?? location;
        about = result['about'] ?? about;
      });
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

  void _showSkillsModal() async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SkillsModal(initialSkills: List.from(skills)),
    );

    if (result != null) {
      setState(() {
        skills = result;
      });
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeader(
              user: profile!['user'], // 🔥 BACKEND USER
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
*/