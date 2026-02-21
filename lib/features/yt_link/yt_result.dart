import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;

import 'package:exam_nector/core/app_notification.dart';
import 'package:exam_nector/features/home_screen/notification.dart';
import 'yt_summary.dart';

class YtResultScreen extends StatefulWidget {
  final SummaryDepth depth;
  final String youtubeUrl;
  final String videoTitle; // ✅ ADDED

  const YtResultScreen({
    super.key,
    required this.depth,
    required this.youtubeUrl,
    required this.videoTitle, // ✅ ADDED
  });

  @override
  State<YtResultScreen> createState() => _YtResultScreenState();
}

class _YtResultScreenState extends State<YtResultScreen> {
  final FlutterTts _tts = FlutterTts();

  String summaryText = "";
  bool generating = true;
  bool isFavourite = false;

  @override
  void initState() {
    super.initState();
    _loadFavourite();
    _startStreaming(); // 🔥 STREAM STARTS HERE
  }

  // ================= VIDEO ID =================
  String get videoId {
    final uri = Uri.tryParse(widget.youtubeUrl);
    if (uri == null) return "";
    if (uri.host.contains("youtu.be")) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : "";
    }
    return uri.queryParameters['v'] ?? "";
  }

  String get thumbnail =>
      "https://img.youtube.com/vi/$videoId/maxresdefault.jpg";

  // ================= STREAM SUMMARY =================
  Future<void> _startStreaming() async {
    try {
      final request = http.Request(
        'POST',
        Uri.parse("http://10.128.114.29:8000/summarize/youtube/stream"),
      );

      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        "youtube_url": widget.youtubeUrl,
        "depth": widget.depth.name,
      });

      final response = await request.send();

      response.stream.transform(utf8.decoder).listen(
        (chunk) {
          setState(() {
            summaryText += chunk;
          });
        },
        onDone: () async {
          setState(() => generating = false);
          await _saveToLibrary(); // ✅ save AFTER full summary
        },
        onError: (_) {
          setState(() {
            summaryText += "\n\nError generating summary.";
            generating = false;
          });
        },
      );
    } catch (_) {
      setState(() {
        summaryText = "Failed to generate summary.";
        generating = false;
      });
    }
  }

  // ================= LIBRARY SAVE =================
  Future<void> _saveToLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    final List items =
        jsonDecode(prefs.getString("library_items") ?? "[]");

    final exists = items.any(
      (e) =>
          e["url"] == widget.youtubeUrl &&
          e["depth"] == widget.depth.name,
    );

    if (exists) return;

    items.add({
      "type": "youtube",
      "title": widget.videoTitle, // ✅ FIXED
      "thumbnail": thumbnail,
      "url": widget.youtubeUrl,
      "depth": widget.depth.name,
      "summary": summaryText,
      "createdAt": DateTime.now().toIso8601String(),
    });

    await prefs.setString("library_items", jsonEncode(items));
  }

  // ================= FAVOURITE =================
  Future<void> _toggleFavourite() async {
    final prefs = await SharedPreferences.getInstance();
    final List favs =
        jsonDecode(prefs.getString("favourite_items") ?? "[]");

    if (isFavourite) {
      favs.removeWhere(
        (e) =>
            e["url"] == widget.youtubeUrl &&
            e["depth"] == widget.depth.name,
      );
    } else {
      favs.add({
        "type": "youtube",
        "title": widget.videoTitle, // ✅ FIXED
        "thumbnail": thumbnail,
        "url": widget.youtubeUrl,
        "depth": widget.depth.name,
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

    setState(() {
      isFavourite = favs.any(
        (e) =>
            e["url"] == widget.youtubeUrl &&
            e["depth"] == widget.depth.name,
      );
    });
  }

  // ================= LISTEN =================
  Future<void> _listen() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.45);
    await _tts.speak(summaryText.replaceAll("\n", ". "));
  }

  // ================= COPY =================
  Future<void> _copy() async {
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
    final file = File("${dir.path}/summary.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> _downloadPdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (_) => pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Text(summaryText),
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file =
        File("${dir.path}/yt_${DateTime.now().millisecondsSinceEpoch}.pdf");

    await file.writeAsBytes(await pdf.save());

    await NotificationService.add(
      AppNotification(
        id: DateTime.now().toString(),
        title: widget.videoTitle, // ✅ NICE BONUS FIX
        description: "YouTube summary PDF ready",
        pdfPath: file.path,
        createdAt: DateTime.now(),
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => file.readAsBytes());
  }

  // ================= SHARE =================
  void _showShareOptions() {
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

  // ================= SUMMARY UI =================
  List<Widget> _buildSummaryLines() {
    return summaryText
        .split("\n")
        .where((l) => l.trim().isNotEmpty)
        .map(
          (l) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l,
              style: const TextStyle(fontSize: 15, height: 1.6),
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF9ED),
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1F2937)),
        title: const Text(
          "Summary Output",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (generating)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Text(
                                "Generating summary...",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ..._buildSummaryLines(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: _listen,
                    icon: const Icon(Icons.volume_up),
                    label: const Text(
                      "Listen to Summary",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _action(Icons.copy, "COPY", _copy),
                _action(Icons.share, "SHARE", _showShareOptions),
                _action(
                  isFavourite ? Icons.favorite : Icons.favorite_border,
                  "FAV",
                  _toggleFavourite,
                  active: isFavourite,
                ),
                _action(Icons.picture_as_pdf, "PDF", _downloadPdf),
              ],
            ),
          ),
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: active ? Colors.red : const Color(0xFFE09F00),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style:
                const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
