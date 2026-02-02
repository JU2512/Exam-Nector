import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'yt_summary.dart';

class YtScanScreen extends StatefulWidget {
  const YtScanScreen({super.key});

  @override
  State<YtScanScreen> createState() => _YtScanScreenState();
}

class _YtScanScreenState extends State<YtScanScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    /// 🔥 FIX 1: Rebuild UI when user pastes/edits link
    _controller.addListener(() {
      setState(() {});
    });
  }

  void _onSummarize() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please paste a YouTube link")),
      );
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _loading = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => YtSummaryScreen(
          youtubeUrl: _controller.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF7EC),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),

                /// HEADER
                Row(
                  children: [
                    /// 🔥 FIX 2: Back button now works
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      "YouTube Summary",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),

                const SizedBox(height: 32),

                /// INPUT CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFF5D7A1)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 10,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.link, size: 18, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            "VIDEO SOURCE",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      /// TEXT FIELD
                      TextField(
                        controller: _controller,
                        keyboardType: TextInputType.url,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: "Paste a YouTube url here",
                          hintStyle: TextStyle(
                            fontSize: 20,
                            color: Color(0xFF9CA3AF),
                          ),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1F2937),
                        ),
                      ),

                      const Divider(height: 32),

                      /// BOTTOM ROW
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Supports shorts & long-form videos",
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final data = await Clipboard.getData(
                                  Clipboard.kTextPlain);
                              if (data?.text != null) {
                                _controller.text = data!.text!;
                              }
                            },
                            child: const Text(
                              "PASTE",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF4B400),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                /// SUMMARIZE BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    /// 🔥 Button activates only when pasted link is NOT empty
                    onPressed: (_controller.text.trim().isEmpty || _loading)
                        ? null
                        : _onSummarize,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF4B400),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      elevation: 8,
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(
                            color: Color(0xFF1F2937),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.auto_awesome,
                                  color: Color(0xFF1F2937)),
                              SizedBox(width: 8),
                              Text(
                                "Summarize",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 56),

                /// BOTTOM INFO
                Column(
                  children: const [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.school,
                        size: 34,
                        color: Color(0xFFF4B400),
                      ),
                    ),
                    SizedBox(height: 18),
                    Text(
                      "Ready to study?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Paste your lecture link above and let Exam-nectar generate concise notes, key takeaways, and flashcards for you.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}