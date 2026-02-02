import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'summary_result_page.dart';

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

  // ================= LOAD LIBRARY =================
  Future<void> _loadLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString("library_items") ?? "[]";
    final List decoded = jsonDecode(raw);

    libraryItems = decoded.cast<Map<String, dynamic>>();
    setState(() {});

    // Fetch missing YouTube titles and thumbnails safely
    for (final item in libraryItems) {
      if (item['type'] == 'youtube') {
        if ((item['title'] ?? "").toString().isEmpty) {
          _fetchYoutubeTitle(item);
        }
        if ((item['thumbnail'] ?? "").toString().isEmpty &&
            item['url'] != null) {
          final videoId = _extractYoutubeId(item['url']);
          if (videoId != null) {
            item['thumbnail'] =
                "https://img.youtube.com/vi/$videoId/hqdefault.jpg";
          }
        }
      }
    }

    final prefs2 = await SharedPreferences.getInstance();
    await prefs2.setString("library_items", jsonEncode(libraryItems));
  }

  // ================= FETCH YOUTUBE TITLE =================
  Future<void> _fetchYoutubeTitle(Map<String, dynamic> item) async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://www.youtube.com/oembed?url=${item['url']}&format=json",
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        item['title'] = data['title'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("library_items", jsonEncode(libraryItems));
        if (mounted) setState(() {});
      }
    } catch (_) {}
  }

  // ================= EXTRACT YOUTUBE ID =================
  String? _extractYoutubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains("youtu.be")) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    } else if (uri.host.contains("youtube.com")) {
      return uri.queryParameters["v"];
    }
    return null;
  }

  // ================= DELETE ITEM =================
  Future<void> _deleteItem(Map<String, dynamic> item) async {
    libraryItems.remove(item);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("library_items", jsonEncode(libraryItems));
    setState(() {});
  }

  // ================= FILTERED ITEMS =================
  List<Map<String, dynamic>> get filteredItems {
    return libraryItems.where((item) {
      final matchesTab =
          selectedTab == 0 ||
          (selectedTab == 1 && item['type'] == 'youtube') ||
          (selectedTab == 2 && item['type'] == 'scan');

      final matchesSearch = (item['title'] ?? "")
          .toLowerCase()
          .contains(searchController.text.toLowerCase());

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
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
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
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 20),
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
            color: isSelected ? const Color(0xFFF4B400) : Colors.white,
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

  // ================= LIST VIEW =================
  Widget _buildList() {
    if (filteredItems.isEmpty) {
      return const Center(
        child: Text("No summaries found",
            style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredItems.length,
      itemBuilder: (_, index) {
        final item = filteredItems[index];

        return Dismissible(
          key: ValueKey(item.hashCode),
          background: _deleteBg(Alignment.centerLeft),
          secondaryBackground: _deleteBg(Alignment.centerRight),
          confirmDismiss: (_) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Delete Summary?"),
                content:
                    const Text("Remove this summary from library?"),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text("Cancel")),
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text("Delete",
                          style: TextStyle(color: Colors.red))),
                ],
              ),
            );
          },
          onDismissed: (_) => _deleteItem(item),
          child: _libraryCard(item),
        );
      },
    );
  }

  Widget _deleteBg(Alignment align) {
    return Container(
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  // ================= CARD =================
  Widget _libraryCard(Map<String, dynamic> item) {
    final bool isYoutube = item['type'] == 'youtube';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SummaryResultPage(item: item),
          ),
        );
      },
      child: Container(
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
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 72,
                height: 72,
                child: item['thumbnail'] != null
                    ? Image.network(
                        item['thumbnail'],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.grey.shade200),
                      )
                    : Container(
                        color: isYoutube
                            ? Colors.black
                            : Colors.grey.shade200,
                        child: Icon(
                          isYoutube
                              ? Icons.play_arrow
                              : Icons.description,
                          color: isYoutube ? Colors.white : Colors.grey,
                          size: 32,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? "Summary",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Source: ${isYoutube ? "YouTube" : "PDF Scan"}",
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFF4B400)),
          ],
        ),
      ),
    );
  }

  Widget _roundIconButton(
      {required IconData icon, VoidCallback? onTap}) {
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