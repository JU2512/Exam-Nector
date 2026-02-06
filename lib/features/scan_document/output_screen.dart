import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/app_notification.dart';
import '../home_screen/notification.dart';

class ScanSummaryOutputScreen extends StatefulWidget {
  /// 🔥 STREAM from backend (document summary stream)
  final Stream<List<int>> stream;

  /// ✅ REQUIRED FOR TITLE + THUMBNAIL
  final String filePath;
  final String fileName;

  const ScanSummaryOutputScreen({
    super.key,
    required this.stream,
    required this.filePath,
    required this.fileName,
  });

  @override
  State<ScanSummaryOutputScreen> createState() =>
      _ScanSummaryOutputScreenState();
}

class _ScanSummaryOutputScreenState extends State<ScanSummaryOutputScreen> {
  final FlutterTts _tts = FlutterTts();

  String summaryText = "";
  bool isFavourite = false;
  bool completed = false;

  StreamSubscription<List<int>>? _subscription;

  // 🎨 COLORS (UNCHANGED)
  static const backgroundLight = Color(0xFFFFF9ED);
  static const backgroundDark = Color(0xFF23200F);
  static const charcoal = Color(0xFF1F2937);
  static const leafGreen = Color(0xFF4CAF50);
  static const nectarGold = Color(0xFFF4B400);
  static const honeyAmber = Color(0xFFE09F00);

  // ================= HELPERS =================

  /// 📌 Clean title from filename
  String get _cleanTitle {
    return widget.fileName
        .replaceAll(RegExp(r'\.[^.]+$'), '')
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .trim();
  }

  /// 📌 Detect image scan
  bool get _isImage {
    final name = widget.fileName.toLowerCase();
    return name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png');
  }

  /// 📌 Source label for UI
  String get _sourceLabel => _isImage ? "Image Scan" : "PDF Scan";

  @override
  void initState() {
    super.initState();
    _startListeningToStream();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _tts.stop();
    super.dispose();
  }

  // ================= STREAM HANDLING =================
  void _startListeningToStream() {
    _subscription = widget.stream.listen(
      (chunk) {
        final text = utf8.decode(chunk);
        setState(() {
          summaryText += text;
        });
      },
      onDone: () async {
        completed = true;
        await _saveToLibrary();
        await _loadFavourite();
        setState(() {});
      },
      onError: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error receiving summary")),
        );
      },
    );
  }

  // ================= SAVE TO LIBRARY =================
  Future<void> _saveToLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    final List stored =
        jsonDecode(prefs.getString("library_items") ?? "[]");

    final exists = stored.any(
      (e) => e["type"] == "scan" && e["summary"] == summaryText,
    );

    if (exists) return;

    stored.add({
      "type": "scan",
      "title": _cleanTitle,                 // ✅ FIXED
      "thumbnail": widget.filePath,         // ✅ FIXED (local file)
      "source": _sourceLabel,               // ✅ FIXED
      "summary": summaryText,
      "createdAt": DateTime.now().toIso8601String(),
    });

    await prefs.setString("library_items", jsonEncode(stored));
  }

  // ================= FAVOURITE =================
  Future<void> _toggleFavourite() async {
    final prefs = await SharedPreferences.getInstance();
    final List favs =
        jsonDecode(prefs.getString("favourite_items") ?? "[]");

    if (isFavourite) {
      favs.removeWhere(
        (e) => e["type"] == "scan" && e["summary"] == summaryText,
      );
    } else {
      favs.add({
        "type": "scan",
        "title": _cleanTitle,               // ✅ FIXED
        "thumbnail": widget.filePath,       // ✅ FIXED
        "source": _sourceLabel,             // ✅ FIXED
        "summary": summaryText,
        "createdAt": DateTime.now().toIso8601String(),
      });
    }

    await prefs.setString("favourite_items", jsonEncode(favs));
    setState(() => isFavourite = !isFavourite);
  }

  Future<void> _loadFavourite() async {
    final prefs = await SharedPreferences.getInstance();
    final List favs =
        jsonDecode(prefs.getString("favourite_items") ?? "[]");

    isFavourite = favs.any(
      (e) => e["type"] == "scan" && e["summary"] == summaryText,
    );
  }

  // ================= LISTEN =================
  Future<void> _listen() async {
    if (summaryText.isEmpty) return;
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.45);
    await _tts.speak(summaryText.replaceAll("\n", ". "));
  }

  // ================= COPY =================
  Future<void> _copy() async {
    if (summaryText.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: summaryText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Summary copied")),
    );
  }

  // ================= PDF =================
  Future<File> _createPdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (_) => pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Text(summaryText),
        ),
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/scan_summary.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> _downloadPdf() async {
    if (!completed) return;

    final file = await _createPdf();

    await NotificationService.add(
      AppNotification(
        id: DateTime.now().toString(),
        title: _cleanTitle,                 // ✅ FIXED
        description: "Document summary PDF available",
        pdfPath: file.path,
        createdAt: DateTime.now(),
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => file.readAsBytes());
  }

  // ================= SHARE =================
  void _shareOptions() {
    if (!completed) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.text_snippet),
            title: const Text("Share Text"),
            onTap: () {
              Navigator.pop(context);
              Share.share(summaryText);
            },
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text("Share PDF"),
            onTap: () async {
              Navigator.pop(context);
              final file = await _createPdf();
              Share.shareXFiles([XFile(file.path)]);
            },
          ),
        ],
      ),
    );
  }

  // ================= UI (UNCHANGED) =================
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? backgroundDark : backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _header(context, isDark),
            _statusBadge(),
            Expanded(child: _content(isDark)),
            _bottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back,
                color: isDark ? Colors.white : charcoal),
          ),
          const Spacer(),
          Text(
            "Summary Output",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : charcoal,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _statusBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: leafGreen.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          completed
              ? const Icon(Icons.check_circle, color: leafGreen)
              : const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
          const SizedBox(width: 6),
          Text(
            completed
                ? "Document Scanned & Summarized"
                : "Generating summary…",
            style: const TextStyle(
                color: leafGreen, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _content(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF18181B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          summaryText.isEmpty ? "Generating…" : summaryText,
          style: TextStyle(
            fontSize: 15,
            height: 1.6,
            color: isDark ? Colors.white : charcoal,
          ),
        ),
      ),
    );
  }

  Widget _bottomActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _action(Icons.copy, "Copy", _copy),
          _action(Icons.share, "Share", _shareOptions),
          _action(
            isFavourite ? Icons.favorite : Icons.favorite_border,
            "Favourite",
            _toggleFavourite,
            active: isFavourite,
          ),
          _action(Icons.picture_as_pdf, "PDF", _downloadPdf),
        ],
      ),
    );
  }

  Widget _action(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool active = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                color: active ? Colors.red : honeyAmber),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: honeyAmber,
            ),
          ),
        ],
      ),
    );
  }
}
