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

  @override
  void initState() {
    super.initState();
    _fetchVideoTitle();
  }

  String get videoId {
    final uri = Uri.tryParse(widget.youtubeUrl);
    if (uri == null) return "";
    if (uri.host.contains("youtu.be")) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : "";
    }
    return uri.queryParameters['v'] ?? "";
  }

  String get thumbnailUrl =>
      videoId.isEmpty ? "" : "https://img.youtube.com/vi/$videoId/maxresdefault.jpg";

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

                  _option(SummaryDepth.easy, "Easy", "Short & Simple • 2 min read"),
                  _option(SummaryDepth.medium, "Medium", "Balanced • 5 min read"),
                  _option(SummaryDepth.long, "Long", "Detailed Notes • 10 min read"),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => YtResultScreen(
                        depth: selected,
                        youtubeUrl: widget.youtubeUrl,
                        videoTitle: videoTitle ?? "YouTube Video", // ✅ PASS TITLE
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF4B400),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  "Generate Summary",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _option(SummaryDepth depth, String title, String subtitle) {
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
            color: isSelected ? const Color(0xFFF4B400) : const Color(0xFFE5E7EB),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(color: Color(0xFF6B7280))),
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
