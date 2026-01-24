import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String _summaryStorageKey = "saved_summaries";

enum SummaryType { youtube, scan }

class SummaryItem {
  final String id;
  final String title;
  final String thumbnail;
  final String summary;
  final SummaryType type;
  bool isFavourite;
  final DateTime createdAt;

  SummaryItem({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.summary,
    required this.type,
    this.isFavourite = false,
    required this.createdAt,
  });

  // ---------- SERIALIZATION ----------
  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "thumbnail": thumbnail,
        "summary": summary,
        "type": type.name,
        "isFavourite": isFavourite,
        "createdAt": createdAt.toIso8601String(),
      };

  factory SummaryItem.fromMap(Map<String, dynamic> map) {
    return SummaryItem(
      id: map["id"],
      title: map["title"],
      thumbnail: map["thumbnail"],
      summary: map["summary"],
      type: SummaryType.values.firstWhere(
        (e) => e.name == map["type"],
      ),
      isFavourite: map["isFavourite"] ?? false,
      createdAt: DateTime.parse(map["createdAt"]),
    );
  }
}

class SummaryStorage {
  /// 🔹 LOAD ALL
  static Future<List<SummaryItem>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_summaryStorageKey);

    if (raw == null) return [];

    final List decoded = jsonDecode(raw);
    return decoded.map((e) => SummaryItem.fromMap(e)).toList();
  }

  /// 🔹 SAVE ALL
  static Future<void> _saveAll(List<SummaryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        jsonEncode(items.map((e) => e.toMap()).toList());
    await prefs.setString(_summaryStorageKey, encoded);
  }

  /// 🔹 ADD OR UPDATE SUMMARY
  static Future<void> upsert(SummaryItem item) async {
    final items = await loadAll();

    final index = items.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      items[index] = item;
    } else {
      items.insert(0, item);
    }

    await _saveAll(items);
  }

  /// ❤️ TOGGLE FAVOURITE
  static Future<bool> toggleFavourite(String id) async {
    final items = await loadAll();
    final index = items.indexWhere((e) => e.id == id);

    if (index == -1) return false;

    items[index].isFavourite = !items[index].isFavourite;
    await _saveAll(items);

    return items[index].isFavourite;
  }

  /// 🔎 GET FAVOURITES
  static Future<List<SummaryItem>> loadFavourites() async {
    final items = await loadAll();
    return items.where((e) => e.isFavourite).toList();
  }

  /// 🔎 FILTER BY TYPE
  static Future<List<SummaryItem>> loadByType(SummaryType type) async {
    final items = await loadAll();
    return items.where((e) => e.type == type).toList();
  }
}
