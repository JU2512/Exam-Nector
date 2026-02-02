import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_nector/features/home_screen/home.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int selectedIndex = -1;
  final TextEditingController _commentController = TextEditingController();

  static const primary = Color(0xFFF4B400);
  static const background = Color(0xFFFEF9F0);
  static const charcoal = Color(0xFF1F2937);
  static const warmGrey = Color(0xFF8E8E93);
  static const successGreen = Color(0xFF4ADE80);

  final List<String> emojis = ["🙁", "😐", "😊", "😍"];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // ---------------- SUBMIT FEEDBACK ----------------
  Future<void> _submitFeedback() async {
    if (selectedIndex == -1) return;

    try {
      await FirebaseFirestore.instance.collection('feedback').add({
        'emoji': emojis[selectedIndex],
        'message': _commentController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        selectedIndex = -1;
        _commentController.clear();
      });

      _showThankYouDialog();
    } catch (e) {
      debugPrint("🔥 FIRESTORE ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to submit feedback. Please try again."),
        ),
      );
    }
  }

  // ---------------- THANK YOU POPUP ----------------
  void _showThankYouDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Stack(
            children: [
              // CARD
              Container(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // CHECK ICON
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: successGreen.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: successGreen,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: successGreen.withOpacity(0.4),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      "Your feedback helps us grow!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: charcoal,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Thank you for sharing. Every bit of insight helps us make Exam-nectar better for your studies.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // CONTINUE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 8,
                        ),
                        child: const Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: charcoal,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // FOOTER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.hub, size: 16, color: Colors.black38),
                        SizedBox(width: 6),
                        Text(
                          "EXAM-NECTAR AI",
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                            color: Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // CLOSE ICON (FIXED)
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------- UI (UNCHANGED) ----------------
  @override
  Widget build(BuildContext context) {
    final bool isEnabled = selectedIndex != -1;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        _circleIcon(Icons.arrow_back, Colors.white, charcoal,
            () => Navigator.pop(context)),
        const Spacer(),
        const Text("Feedback",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const Spacer(),
        _circleIcon(Icons.close, Colors.grey.shade400, Colors.white,
            () => Navigator.pop(context)),
      ],
    );
  }

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

  Widget _quote() => const Center(
        child: Text(
          "\"We value your opinion.\"",
          style: TextStyle(
            fontSize: 22,
            fontStyle: FontStyle.italic,
            color: Color(0xFFE09F00),
          ),
        ),
      );

  Widget _question() => const Center(
        child: Text(
          "How was your experience?",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      );

  Widget _emojis() {
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
                ),
                child: Text(emojis[i], style: const TextStyle(fontSize: 30)),
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

  Widget _commentBox() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: TextField(
        controller: _commentController,
        expands: true,
        maxLines: null,
        decoration: const InputDecoration(
          hintText: "Add your comments here...",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _sendButton(bool enabled) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: enabled ? _submitFeedback : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? primary : primary.withOpacity(0.4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
        child: const Text(
          "Send Feedback",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: charcoal,
          ),
        ),
      ),
    );
  }

  Widget _circleIcon(
      IconData icon, Color bg, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: color),
      ),
    );
  }
}
