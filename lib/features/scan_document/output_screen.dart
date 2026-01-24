import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ScanSummaryOutputScreen extends StatefulWidget {
  final String summaryText;

  const ScanSummaryOutputScreen({
    super.key,
    required this.summaryText,
  });

  @override
  State<ScanSummaryOutputScreen> createState() =>
      _ScanSummaryOutputScreenState();
}

class _ScanSummaryOutputScreenState extends State<ScanSummaryOutputScreen> {
  final FlutterTts _tts = FlutterTts();
  bool isFavourite = false;

  // 🎨 COLORS
  static const backgroundLight = Color(0xFFFFF9ED);
  static const backgroundDark = Color(0xFF23200F);
  static const charcoal = Color(0xFF1F2937);
  static const leafGreen = Color(0xFF4CAF50);
  static const nectarGold = Color(0xFFF4B400);
  static const honeyAmber = Color(0xFFE09F00);

  @override
  void initState() {
    super.initState();
    _loadFavourite();
  }

  // 🔊 LISTEN
  Future<void> _listen() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.45);
    await _tts.speak(widget.summaryText);
  }

  // 📋 COPY
  Future<void> _copy() async {
    await Clipboard.setData(
      ClipboardData(text: widget.summaryText),
    );
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Summary copied")));
  }

  // ❤️ FAVOURITE
  Future<void> _toggleFavourite() async {
    final prefs = await SharedPreferences.getInstance();
    const key = "scan_summary_fav";

    if (isFavourite) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, widget.summaryText);
    }

    setState(() => isFavourite = !isFavourite);
  }

  Future<void> _loadFavourite() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => isFavourite = prefs.containsKey("scan_summary_fav"));
  }

  // 📄 CREATE PDF
  Future<File> _createPdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (_) => pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Text(
            widget.summaryText,
            style: const pw.TextStyle(fontSize: 14),
          ),
        ),
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/summary.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // ⬇️ DOWNLOAD PDF
  Future<void> _downloadPdf() async {
    final file = await _createPdf();
    await Printing.layoutPdf(
      onLayout: (_) => file.readAsBytes(),
    );
  }

  // 🔗 SHARE OPTIONS
  void _shareOptions() {
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
              Share.share(widget.summaryText);
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

  // ---------------- UI ----------------
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
            _bottomActions(isDark),
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
                color: isDark ? Colors.white : charcoal),
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
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: leafGreen),
          SizedBox(width: 6),
          Text("Document Scanned & Summarized",
              style: TextStyle(
                  color: leafGreen, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _content(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF18181B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.summaryText,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: isDark ? Colors.white : charcoal,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 56,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _listen,
              icon: const Icon(Icons.volume_up),
              label: const Text("Listen to Summary"),
              style: ElevatedButton.styleFrom(
                backgroundColor: nectarGold,
                foregroundColor: charcoal,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomActions(bool isDark) {
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
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                color: active ? Colors.red : honeyAmber),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: honeyAmber)),
        ],
      ),
    );
  }
}
