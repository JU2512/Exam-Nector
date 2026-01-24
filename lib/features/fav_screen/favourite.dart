import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum FavType { youtube, document }

class FavouriteItem {
  String title;
  final String image;
  final FavType type;
  final bool isVideo;
  final String? youtubeUrl;

  FavouriteItem({
    required this.title,
    required this.image,
    required this.type,
    this.isVideo = false,
    this.youtubeUrl,
  });
}

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  String selectedTab = "All";

  static const bg = Color(0xFFFFF9ED);
  static const primary = Color(0xFFF4B400);

  List<FavouriteItem> allItems = [];

  @override
  void initState() {
    super.initState();
    _loadFavourites();
  }

  // ================= LOAD FAVOURITES =================
  Future<void> _loadFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    final List stored =
        jsonDecode(prefs.getString("favourite_items") ?? "[]");

    final items = stored.map<FavouriteItem>((e) {
      final isYoutube = e['type'] == 'youtube';

      return FavouriteItem(
        title: e['title'] ?? "Loading...",
        image: e['thumbnail'] ??
            "https://ui-avatars.com/api/?name=Doc",
        type: isYoutube ? FavType.youtube : FavType.document,
        isVideo: isYoutube,
        youtubeUrl: e['youtubeUrl'],
      );
    }).toList();

    setState(() => allItems = items);

    for (final item in items) {
      if (item.type == FavType.youtube && item.youtubeUrl != null) {
        _fetchYoutubeTitle(item);
      }
    }
  }

  // ================= FETCH YOUTUBE TITLE =================
  Future<void> _fetchYoutubeTitle(FavouriteItem item) async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://www.youtube.com/oembed?url=${item.youtubeUrl}&format=json",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => item.title = data['title']);
      }
    } catch (_) {}
  }

  // ================= REMOVE FAVOURITE =================
  Future<void> _removeFavourite(FavouriteItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final List stored =
        jsonDecode(prefs.getString("favourite_items") ?? "[]");

    stored.removeWhere((e) =>
        e['youtubeUrl'] == item.youtubeUrl &&
        e['type'] == item.type.name);

    await prefs.setString(
        "favourite_items", jsonEncode(stored));

    setState(() {
      allItems.remove(item);
    });
  }

  List<FavouriteItem> get filteredItems {
    if (selectedTab == "YouTube") {
      return allItems.where((e) => e.type == FavType.youtube).toList();
    }
    if (selectedTab == "Documents") {
      return allItems.where((e) => e.type == FavType.document).toList();
    }
    return allItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            _tabs(),
            Expanded(child: _grid()),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          const Text(
            "Favourites",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ================= TABS =================
  Widget _tabs() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            _tab("All"),
            _tab("YouTube"),
            _tab("Documents"),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label) {
    final active = selectedTab == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // ================= GRID =================
  Widget _grid() {
    if (filteredItems.isEmpty) {
      return const Center(
        child: Text("No favourites yet",
            style: TextStyle(color: Colors.grey)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        itemCount: filteredItems.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          mainAxisExtent: 290,
        ),
        itemBuilder: (_, i) => _card(filteredItems[i]),
      ),
    );
  }

  // ================= CARD =================
  Widget _card(FavouriteItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(item.image,
                    fit: BoxFit.cover, width: double.infinity),
              ),
              if (item.isVideo)
                Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.play_arrow, color: primary),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.type == FavType.youtube ? "YOUTUBE" : "DOCUMENT",
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),

            // ❤️ REMOVE FROM FAVOURITE
            GestureDetector(
              onTap: () => _removeFavourite(item),
              child: const Icon(Icons.favorite, color: primary),
            ),
          ],
        ),
      ],
    );
  }
}