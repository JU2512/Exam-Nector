import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LibraryApp extends StatefulWidget {
  const LibraryApp({super.key});

  @override
  State<LibraryApp> createState() => _LibraryAppState();
}

class _LibraryAppState extends State<LibraryApp> {
  int selectedTab = 0;
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> libraryItems = [];

  @override
  void initState() {
    super.initState();
    _loadLibrary();
  }

  // ================= LOAD FROM STORAGE =================
  Future<void> _loadLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    final List stored =
        jsonDecode(prefs.getString("library_items") ?? "[]");

    final List<Map<String, dynamic>> items =
        stored.cast<Map<String, dynamic>>();

    setState(() => libraryItems = items);

    // 🔥 Fetch YouTube titles if missing
    for (final item in items) {
      if (item['type'] == 'youtube' &&
          (item['videoTitle'] == null ||
              item['videoTitle'].toString().isEmpty)) {
        _fetchYoutubeTitle(item);
      }
    }
  }

  // ================= FETCH YOUTUBE TITLE =================
  Future<void> _fetchYoutubeTitle(Map<String, dynamic> item) async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://www.youtube.com/oembed?url=${item['youtubeUrl']}&format=json",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        item['videoTitle'] = data['title'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          "library_items",
          jsonEncode(libraryItems),
        );

        if (mounted) setState(() {});
      }
    } catch (_) {}
  }

  // ================= FILTER =================
  List<Map<String, dynamic>> get filteredItems {
    return libraryItems.where((item) {
      final matchesTab =
          selectedTab == 0 ||
          (selectedTab == 1 && item['type'] == 'youtube') ||
          (selectedTab == 2 && item['type'] == 'scan');

      final matchesSearch =
          (item['videoTitle'] ?? item['title'])
                  ?.toLowerCase()
                  .contains(searchController.text.toLowerCase()) ??
              false;

      return matchesTab && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9ED),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF9ED),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _roundIconButton(
                icon: Icons.arrow_back,
                onTap: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    "Library",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 20),

          // SEARCH
          TextField(
            controller: searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: "Search your library...",
              prefixIcon:
                  const Icon(Icons.search, color: Color(0xFFF4B400)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // TABS
          Row(
            children: [
              _tabButton("All", 0),
              const SizedBox(width: 8),
              _tabButton("YouTube", 1),
              const SizedBox(width: 8),
              _tabButton("Scans", 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final bool isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFF4B400)
                : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  // ================= LIST =================
  Widget _buildList() {
    if (filteredItems.isEmpty) {
      return const Center(
        child: Text(
          "No summaries found",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredItems.length,
      itemBuilder: (_, index) => _libraryCard(filteredItems[index]),
    );
  }

  // ================= CARD =================
  Widget _libraryCard(Map<String, dynamic> item) {
    final bool isYoutube = item['type'] == 'youtube';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isYoutube ? Colors.black : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
              image: isYoutube && item['thumbnail'] != null
                  ? DecorationImage(
                      image: NetworkImage(item['thumbnail']),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: isYoutube
                ? const Icon(Icons.play_arrow,
                    color: Colors.white, size: 32)
                : const Icon(Icons.description,
                    color: Colors.grey, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (item['videoTitle'] ?? item['title']) ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Source: ${isYoutube ? "YouTube" : "PDF Scan"}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: Color(0xFFF4B400)),
        ],
      ),
    );
  }

  Widget _roundIconButton({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon),
      ),
    );
  }
}