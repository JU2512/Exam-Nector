import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_filex/open_filex.dart';
import 'package:exam_nector/core/app_notification.dart';

/// ================= SERVICE =================
class NotificationService {
  static const _key = "app_notifications";

  static Future<List<AppNotification>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];

    final List decoded = jsonDecode(raw);
    return decoded.map((e) => AppNotification.fromJson(e)).toList();
  }

  static Future<void> add(AppNotification notification) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getAll();

    existing.insert(0, notification);

    await prefs.setString(
      _key,
      jsonEncode(existing.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> markAllRead() async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAll();

    for (var item in list) {
      item.unread = false;
    }

    await prefs.setString(
      _key,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }
}

/// ================= NOTIFICATION SCREEN =================
class NotificationServiceScreen extends StatefulWidget {
  const NotificationServiceScreen({super.key});

  @override
  State<NotificationServiceScreen> createState() =>
      _NotificationServiceScreenState();
}

class _NotificationServiceScreenState
    extends State<NotificationServiceScreen> {
  List<AppNotification> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    notifications = await NotificationService.getAll();
    setState(() {});
  }

  Future<void> _openPdf(AppNotification n) async {
    final file = File(n.pdfPath);

    if (!file.existsSync()) return;

    await OpenFilex.open(file.path);

    if (n.unread) {
      setState(() => n.unread = false);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        "app_notifications",
        jsonEncode(notifications.map((e) => e.toJson()).toList()),
      );
    }
  }

  void _markAllRead() async {
    await NotificationService.markAllRead();
    _loadNotifications();
  }

  /// HELPER: Time formatting
  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays == 1) return "Yesterday";
    return "${diff.inDays} days ago";
  }

  IconData _iconFor(AppNotification n) {
    if (n.description.toLowerCase().contains("youtube")) {
      return Icons.play_arrow;
    }
    return Icons.picture_as_pdf;
  }

  List<AppNotification> get recent => notifications
      .where((n) => DateTime.now().difference(n.createdAt).inHours < 24)
      .toList();

  List<AppNotification> get earlier => notifications
      .where((n) => DateTime.now().difference(n.createdAt).inHours >= 24)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF9ED),
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1F2937)),
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF1F2937)),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader("RECENT", action: _markAllRead),
          ...recent.map(_notificationCard),
          const SizedBox(height: 24),
          _sectionHeader("EARLIER"),
          ...earlier.map(_notificationCard),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, {VoidCallback? action}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B7280),
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: action,
              child: const Text(
                "Mark all as read",
                style: TextStyle(
                  color: Color(0xFFF4B400),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _notificationCard(AppNotification n) {
    return GestureDetector(
      onTap: () => _openPdf(n),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF4B400).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_iconFor(n), color: const Color(0xFFF4B400)),
            ),
            const SizedBox(width: 14),

            /// 🔥 NOW SHOWING ORIGINAL VIDEO TITLE
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        _timeAgo(n.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    n.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Column(
              children: [
                if (n.unread)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF4B400),
                      shape: BoxShape.circle,
                    ),
                  ),
                const SizedBox(height: 8),
                const Icon(Icons.chevron_right,
                    color: Color(0xFF9CA3AF)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}