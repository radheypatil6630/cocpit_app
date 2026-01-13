import 'package:flutter/material.dart';
import '../bottom_navigation.dart';
import '../../widgets/app_top_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppTopBar(
        searchType: SearchType.chat,
        controller: _searchController,
        onChanged: (v) => setState(() {}),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 💬 Messages List
          Expanded(
            child: ListView(
              children: [
                _ChatTile(
                  name: "Michael Chen",
                  role: "Recruiter",
                  message: "Thanks for connecting! Looking forwar...",
                  time: "2m ago",
                  unreadCount: 2,
                  color: Colors.blueAccent,
                  isOnline: true,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalChatScreen(name: "Michael Chen", role: "Recruiter", color: Colors.blueAccent))),
                ),
                _ChatTile(
                  name: "Emily Rodriguez",
                  role: "Hiring Manager",
                  message: "That sounds great! When would be a good ...",
                  time: "1h ago",
                  unreadCount: 0,
                  color: Colors.pinkAccent,
                  isOnline: true,
                  onTap: () {},
                ),
                _ChatTile(
                  name: "David Park",
                  role: "Connection",
                  message: "I saw your recent post about AI trends...",
                  time: "3h ago",
                  unreadCount: 1,
                  color: Colors.deepPurpleAccent,
                  isOnline: false,
                  onTap: () {},
                ),
                _ChatTile(
                  name: "Jessica Williams",
                  role: "Talent Acquisition",
                  message: "Happy to help with that project!",
                  time: "1d ago",
                  unreadCount: 0,
                  color: Colors.greenAccent,
                  isOnline: false,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final String name;
  final String role;
  final String message;
  final String time;
  final int unreadCount;
  final Color color;
  final bool isOnline;
  final VoidCallback onTap;

  const _ChatTile({
    required this.name,
    required this.role,
    required this.message,
    required this.time,
    required this.unreadCount,
    required this.color,
    required this.isOnline,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.dividerColor, width: 0.5)),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: color,
                ),
                if (isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        time,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      role,
                      style: TextStyle(color: theme.primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: theme.primaryColor, shape: BoxShape.circle),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PersonalChatScreen extends StatefulWidget {
  final String name;
  final String role;
  final Color color;

  const PersonalChatScreen({super.key, required this.name, required this.role, required this.color});

  @override
  State<PersonalChatScreen> createState() => _PersonalChatScreenState();
}

class _PersonalChatScreenState extends State<PersonalChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'text': 'Hi! Thanks for accepting my connection request!', 'isMe': false, 'time': '10:30 AM'},
    {'text': 'I\'m reaching out regarding the Senior React role.', 'isMe': false, 'time': '10:31 AM'},
    {'text': 'Hi Michael! Thanks for reaching out.', 'isMe': true, 'time': '10:32 AM'},
    {'text': 'I\'d love to hear more about the team.', 'isMe': true, 'time': '10:32 AM'},
    {'text': 'Great! Do you have time for a quick call this week?', 'isMe': false, 'time': '10:33 AM'},
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'text': _messageController.text.trim(),
          'isMe': true,
          'time': TimeOfDay.now().format(context),
        });
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: colorScheme.onSurface),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(radius: 18, backgroundColor: widget.color),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: theme.scaffoldBackgroundColor, width: 1.5)),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(widget.role, style: TextStyle(color: theme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.call_outlined, color: colorScheme.onSurface), onPressed: () {}),
          IconButton(icon: Icon(Icons.more_vert, color: colorScheme.onSurface), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: theme.primaryColor.withValues(alpha: 0.05),
            child: Text(
              "Context: Senior React Developer Role",
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.primaryColor, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                bool showTime = index == _messages.length - 1 || _messages[index + 1]['isMe'] != msg['isMe'];
                return Column(
                  crossAxisAlignment: msg['isMe'] ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: msg['isMe'] ? theme.primaryColor : colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: msg['isMe'] ? null : Border.all(color: theme.dividerColor),
                      ),
                      child: Text(
                        msg['text'],
                        style: TextStyle(
                          color: msg['isMe'] ? Colors.white : colorScheme.onSurface,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (showTime)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
                        child: Text(
                          msg['time'],
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          _buildMessageInput(theme),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          IconButton(icon: Icon(Icons.add, color: theme.primaryColor), onPressed: () {}),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.dividerColor),
              ),
              child: TextField(
                controller: _messageController,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: "Write a message...",
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.4)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send, color: theme.primaryColor),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
