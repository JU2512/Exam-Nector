import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'yt_result.dart';

enum SummaryDepth { easy, medium, long }

class YtSummaryScreen extends StatefulWidget {
  final String youtubeUrl;

  const YtSummaryScreen({
    super.key,
    required this.youtubeUrl,
  });

  @override
  State<YtSummaryScreen> createState() => _YtSummaryScreenState();
}

class _YtSummaryScreenState extends State<YtSummaryScreen> {
  SummaryDepth selected = SummaryDepth.easy;
  String? videoTitle;
  bool loadingTitle = true;
  bool generating = false;

  @override
  void initState() {
    super.initState();
    _fetchVideoTitle();
  }

  /// 🔹 Extract YouTube Video ID
  String get videoId {
    final uri = Uri.tryParse(widget.youtubeUrl);
    if (uri == null) return "";

    if (uri.host.contains("youtu.be")) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : "";
    }

    return uri.queryParameters['v'] ?? "";
  }

  /// 🔹 Thumbnail URL (NEW – logic only)
  String get thumbnailUrl {
    if (videoId.isEmpty) return "";
    return "https://img.youtube.com/vi/$videoId/maxresdefault.jpg";
  }

  /// 🔹 Fetch video title (NO API KEY)
  Future<void> _fetchVideoTitle() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://www.youtube.com/oembed?url=${widget.youtubeUrl}&format=json",
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          videoTitle = data['title'];
          loadingTitle = false;
        });
      } else {
        _fallbackTitle();
      }
    } catch (_) {
      _fallbackTitle();
    }
  }

  void _fallbackTitle() {
    setState(() {
      videoTitle = "YouTube Video";
      loadingTitle = false;
    });
  }

  /// 🔥 BACKEND CALL (UNCHANGED)
  Future<void> _generateSummary() async {
    setState(() => generating = true);

    try {
      final response = await http.post(
        Uri.parse("http://10.152.161.29:8000/summarize/youtube"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "youtube_url": widget.youtubeUrl,
          "depth": selected.name,
        }),
      );

      setState(() => generating = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawSummary = data["summary"];

        final String summaryText = rawSummary is List
            ? rawSummary.join("\n\n")
            : rawSummary.toString();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => YtResultScreen(
              depth: selected,
              youtubeUrl: widget.youtubeUrl,
              summaryText: summaryText,
            ),
          ),
        );
      } else {
        _showError("Failed to generate summary");
      }
    } catch (e) {
      setState(() => generating = false);
      _showError("Network error");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF7EC),
        elevation: 0,
        leading: const BackButton(color: Color(0xFF1F2937)),
        title: const Text(
          "Summary Type",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🎬 THUMBNAIL (UNCHANGED UI)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.network(
                      thumbnailUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// 🎯 TITLE
                  loadingTitle
                      ? const LinearProgressIndicator(
                          color: Color(0xFFF4B400),
                        )
                      : Text(
                          videoTitle ?? "",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                  const SizedBox(height: 28),

                  const Text(
                    "Select summary depth:",
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),

                  const SizedBox(height: 16),

                  _option(SummaryDepth.easy, "Easy",
                      "Short & Simple • 2 min read"),
                  _option(SummaryDepth.medium, "Medium",
                      "Technical & Balanced • 5 min read"),
                  _option(SummaryDepth.long, "Long",
                      "Detailed Notes • 10 min read"),
                ],
              ),
            ),
          ),

          /// 🔘 GENERATE BUTTON
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: generating ? null : _generateSummary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF4B400),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: generating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Generate Summary",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _option(
    SummaryDepth depth,
    String title,
    String subtitle,
  ) {
    final isSelected = selected == depth;

    return GestureDetector(
      onTap: () => setState(() => selected = depth),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFF4B400)
                : const Color(0xFFE5E7EB),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style:
                        const TextStyle(color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected
                  ? const Color(0xFFF4B400)
                  : const Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }
}
