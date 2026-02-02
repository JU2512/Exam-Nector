import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'summary_result_page.dart';

enum FavType { youtube, document }

class FavouriteItem {
  final String title;
  final String image;
  final FavType type;
  final bool isVideo;
  final String summary;

  FavouriteItem({
    required this.title,
    required this.image,
    required this.type,
    required this.summary,
    this.isVideo = false,
  });

  factory FavouriteItem.fromJson(Map<String, dynamic> json) {
    return FavouriteItem(
      title: json["title"] ?? "Summary",
      image: json["thumbnail"] ??
          "https://via.placeholder.com/300x200.png?text=Document",
      type:
          json["type"] == "youtube" ? FavType.youtube : FavType.document,
      isVideo: json["type"] == "youtube",
      summary: json["summary"] ?? "",
    );
  }
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

  // ================= LOAD =================
  Future<void> _loadFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString("favourite_items") ?? "[]";
    final List decoded = jsonDecode(raw);

    setState(() {
      allItems =
          decoded.map((e) => FavouriteItem.fromJson(e)).toList();
    });
  }

  // ================= CENTER POPUP =================
  void _confirmRemove(FavouriteItem item) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: bg,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_border,
                      color: primary, size: 28),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Remove from favourites?",
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "You can add it back anytime from the summary page.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      await _removeFavourite(item);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Remove",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= REMOVE =================
  Future<void> _removeFavourite(FavouriteItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString("favourite_items") ?? "[]";
    final List decoded = jsonDecode(raw);

    decoded.removeWhere((e) =>
        e["summary"] == item.summary &&
        e["type"] ==
            (item.type == FavType.youtube ? "youtube" : "scan"));

    await prefs.setString("favourite_items", jsonEncode(decoded));
    _loadFavourites();
  }

  // ================= FILTER =================
  List<FavouriteItem> get filteredItems {
    if (selectedTab == "YouTube") {
      return allItems.where((e) => e.type == FavType.youtube).toList();
    }
    if (selectedTab == "Documents") {
      return allItems.where((e) => e.type == FavType.document).toList();
    }
    return allItems;
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _tabs(),
            Expanded(child: _grid()),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          const BackButton(),
          const SizedBox(width: 8),
          const Text(
            "Favourites",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: 20),
          )
        ],
      ),
    );
  }

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
          childAspectRatio: 0.65, // ✅ Prevents overflow
        ),
        itemBuilder: (_, i) => _card(filteredItems[i]),
      ),
    );
  }

  // ================= CARD =================
  Widget _card(FavouriteItem item) {
    final bool isFile = item.image.startsWith("/");

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SummaryResultPage(
              item: {
                "title": item.title,
                "summary": item.summary,
                "type": item.type == FavType.youtube
                    ? "youtube"
                    : "scan",
              },
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: isFile && File(item.image).existsSync()
                      ? Image.file(
                          File(item.image),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      : Image.network(
                          item.image,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
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
                      child: const Icon(Icons.play_arrow,
                          color: primary),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.type == FavType.youtube
                    ? "YOUTUBE"
                    : "DOCUMENT",
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
              GestureDetector(
                onTap: () => _confirmRemove(item),
                child:
                    const Icon(Icons.favorite, color: primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}