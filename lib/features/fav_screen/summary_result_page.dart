import 'package:flutter/material.dart';

class SummaryResultPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const SummaryResultPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final String title = item['title'] ?? "Summary";
    final String summary = item['summary'] ?? "No summary available.";
    final bool isYoutube = item['type'] == 'youtube';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF9ED),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Summary",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Source: ${isYoutube ? "YouTube" : "PDF Scan"}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  summary,
                  style:
                      const TextStyle(fontSize: 15, height: 1.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
