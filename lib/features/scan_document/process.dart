import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'output_screen.dart';

class ProcessScreen extends StatefulWidget {
  final File file;
  final String fileName;

  const ProcessScreen({
    super.key,
    required this.file,
    required this.fileName,
  });

  @override
  State<ProcessScreen> createState() => _ProcessScreenState();
}

class _ProcessScreenState extends State<ProcessScreen> {
  String selectedType = "easy";
  bool loading = false;

  final Color primary = const Color(0xFFE09F00);
  final Color background = const Color(0xFFFFF9ED);
  final Color card = Colors.white;

  Future<void> _generateSummary() async {
    setState(() => loading = true);

    try {
      final uri =
          Uri.parse("http://10.152.161.29:8000/summarize/document");

      final request = http.MultipartRequest("POST", uri);

      request.fields["depth"] = selectedType;
      request.files.add(
        await http.MultipartFile.fromPath(
          "file",
          widget.file.path,
          filename: widget.fileName,
        ),
      );

      final streamedResponse = await request.send();
      final response =
          await http.Response.fromStream(streamedResponse);

      setState(() => loading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScanSummaryOutputScreen(
              summaryText: data["summary"],
            ),
          ),
        );
      } else {
        _showError("Failed to process document");
      }
    } catch (e) {
      setState(() => loading = false);
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
      backgroundColor: background,

      // ===== HEADER =====
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Summary Type",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _progressIndicator(),
            const SizedBox(height: 28),

            const Text(
              "Almost ready!",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "Choose the depth of your AI-generated summary.",
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 24),

            _optionCard(
              value: "easy",
              title: "Easy",
              description: "Simple, exam-oriented & quick to read.",
              icon: Icons.bolt,
            ),
            _optionCard(
              value: "medium",
              title: "Medium",
              description: "Balanced explanation with key concepts.",
              icon: Icons.auto_awesome,
            ),
            _optionCard(
              value: "long",
              title: "Long",
              description: "Detailed notes for deep understanding.",
              icon: Icons.description,
            ),

            const Spacer(),

            // ===== CTA BUTTON =====
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: loading ? null : _generateSummary,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Generate Summary",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.auto_fix_high),
                      ],
                    ),
            ),

            const SizedBox(height: 14),
            const Center(
              child: Text(
                "Exam-Nectar uses AI to process your documents securely.",
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== PROGRESS BAR =====
  Widget _progressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(false),
        _dot(true),
        _dot(false),
      ],
    );
  }

  Widget _dot(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 36 : 20,
      height: 6,
      decoration: BoxDecoration(
        color: active ? primary : primary.withOpacity(0.25),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  // ===== OPTION CARD =====
  Widget _optionCard({
    required String value,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final bool selected = selectedType == value;

    return GestureDetector(
      onTap: () => setState(() => selectedType = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? primary.withOpacity(0.08) : card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: primary.withOpacity(0.15),
              child: Icon(icon, color: primary),
            ),
            const SizedBox(width: 14),
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
                    description,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? primary : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            )
          ],
        ),
      ),
    );
  }
}
