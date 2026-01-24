import 'package:flutter/material.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int selectedIndex = -1; // ❌ no selection initially

  static const primary = Color(0xFFF4B400);
  static const background = Color(0xFFFEF9F0);
  static const charcoal = Color(0xFF1F2937);
  static const warmGrey = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = selectedIndex != -1;

    return Scaffold(
      backgroundColor: background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(context),
                const SizedBox(height: 24),
                _badge(),
                const SizedBox(height: 20),
                _quote(),
                const SizedBox(height: 32),
                _question(),
                const SizedBox(height: 24),
                _emojis(),
                const SizedBox(height: 32),
                _commentBox(),
                const SizedBox(height: 32),
                _sendButton(isEnabled),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _header(BuildContext context) {
    return Row(
      children: [
        _circleIcon(Icons.arrow_back, Colors.white, charcoal,
            () => Navigator.pop(context)),
        const Spacer(),
        const Text(
          "Feedback",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        _circleIcon(Icons.close, Colors.grey.shade400, Colors.white,
            () => Navigator.pop(context)),
      ],
    );
  }

  // ---------------- BADGE ----------------
  Widget _badge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Text(
          "ACADEMIC QUALITY",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: primary,
          ),
        ),
      ),
    );
  }

  // ---------------- QUOTE ----------------
  Widget _quote() {
    return const Center(
      child: Text(
        "\"We value your opinion.\"",
        style: TextStyle(
          fontSize: 22,
          fontStyle: FontStyle.italic,
          color: Color(0xFFE09F00),
        ),
      ),
    );
  }

  // ---------------- QUESTION ----------------
  Widget _question() {
    return const Center(
      child: Text(
        "How was your experience?",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ---------------- EMOJIS ----------------
  Widget _emojis() {
    final emojis = ["🙁", "😐", "😊", "😍"];
    final labels = ["BAD", "OKAY", "GOOD", "GREAT"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (i) {
        final selected = selectedIndex == i;
        return GestureDetector(
          onTap: () => setState(() => selectedIndex = i),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: selected
                          ? primary.withOpacity(0.4)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Text(
                  emojis[i],
                  style: const TextStyle(fontSize: 30),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                labels[i],
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: warmGrey,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ---------------- COMMENT BOX ----------------
  Widget _commentBox() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: const TextField(
        maxLines: null,
        expands: true,
        decoration: InputDecoration(
          hintText: "Add your comments here...",
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ---------------- SEND BUTTON ----------------
  Widget _sendButton(bool enabled) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: enabled ? () {} : null, // ✅ DISABLED WHEN NO RATING
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? primary : primary.withOpacity(0.4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          elevation: enabled ? 8 : 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "Send Feedback",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: charcoal,
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward, color: charcoal),
          ],
        ),
      ),
    );
  }

  // ---------------- ICON BUTTON ----------------
  Widget _circleIcon(
      IconData icon, Color bg, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
}