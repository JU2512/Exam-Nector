import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const bg = Color(0xFFFFF9ED);
  static const primary = Color(0xFFF4B400);
  static const charcoal = Color(0xFF1F2937);
  static const warmGrey = Color(0xFF6B7280);

  List<bool> unread = [true, true, false, false, false];

  void _markAllRead() {
    setState(() {
      unread = unread.map((_) => false).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _sectionHeader("Recent", showAction: true),
                  _notificationCard(
                    index: 0,
                    icon: Icons.play_circle,
                    title: "AI Ethics Summary Ready",
                    time: "2m ago",
                    description:
                        "Your summary for 'The Future of AI' is now available for review.",
                  ),
                  _notificationCard(
                    index: 1,
                    icon: Icons.document_scanner,
                    title: "Textbook Chapter 4",
                    time: "15m ago",
                    description:
                        "OCR processing complete. View your key takeaways from the scan.",
                  ),
                  const SizedBox(height: 24),
                  _sectionHeader("Earlier"),
                  _notificationCard(
                    index: 2,
                    icon: Icons.article,
                    title: "Quantum Physics Intro",
                    time: "2h ago",
                    description:
                        "Detailed notes generated from your saved link are ready in your library.",
                  ),
                  _notificationCard(
                    index: 3,
                    icon: Icons.language,
                    title: "History of Rome",
                    time: "Yesterday",
                    description:
                        "Summary archived to your 'History' collection successfully.",
                  ),
                  _notificationCard(
                    index: 4,
                    icon: Icons.mic,
                    title: "Podcast: Tech 2024",
                    time: "2 days ago",
                    description:
                        "Audio transcription and insights are now complete.",
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          bottom: BorderSide(color: primary.withOpacity(0.15)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: charcoal),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              "Notifications",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: charcoal,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: charcoal),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // ---------------- SECTION HEADER ----------------
  Widget _sectionHeader(String title, {bool showAction = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.4,
              fontWeight: FontWeight.bold,
              color: charcoal.withOpacity(0.7),
            ),
          ),
          if (showAction)
            GestureDetector(
              onTap: _markAllRead,
              child: const Text(
                "Mark all as read",
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------- NOTIFICATION CARD ----------------
  Widget _notificationCard({
    required int index,
    required IconData icon,
    required String title,
    required String time,
    required String description,
  }) {
    final bool isUnread = unread[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: charcoal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: warmGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: warmGrey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isUnread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                ),
              const SizedBox(height: 8),
              const Icon(Icons.chevron_right,
                  color: Color(0xFF9CA3AF)),
            ],
          )
        ],
      ),
    );
  }
}