import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'process.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  // 🎨 COLORS — EXACT AS IMAGE
  static const Color warmCream = Color(0xFFFFF9ED);
  static const Color charcoal = Color(0xFF1F2937);
  static const Color nectarGold = Color(0xFFF4B400);
  static const Color softWhite = Color(0xFFFFFFFF);
  static const Color deepHoney = Color(0xFFE09F00);

  final ImagePicker _picker = ImagePicker();

  File? selectedFile;
  String? fileName;

  // ================= CAMERA =================
  Future<void> _openCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) return;

    final XFile? image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);

    if (image != null) {
      setState(() {
        selectedFile = File(image.path);
        fileName = image.name;
      });
    }
  }

  // ================= GALLERY =================
  Future<void> _openGallery() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (image != null) {
      setState(() {
        selectedFile = File(image.path);
        fileName = image.name;
      });
    }
  }

  // ================= IMAGE OPTIONS =================
  void _pickImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: nectarGold),
              title: const Text("Open Camera"),
              onTap: () {
                Navigator.pop(context);
                _openCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: nectarGold),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _openGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= PDF PICK =================
  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.single.path == null) return;

    setState(() {
      selectedFile = File(result.files.single.path!);
      fileName = result.files.single.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warmCream,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: warmCream,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: charcoal),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Scan Document",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: charcoal,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            // ================= MAIN SCAN CARD =================
            GestureDetector(
              onTap: _pickImageOptions,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                decoration: BoxDecoration(
                  color: softWhite,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: nectarGold, width: 2),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: nectarGold, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: nectarGold,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Tap to Scan or Upload",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: charcoal,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Place your document within the frame to scan automatically",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 6),
                      decoration: BoxDecoration(
                        color: nectarGold.withOpacity(.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "AUTO-DETECTION ACTIVE",
                        style: TextStyle(
                          color: deepHoney,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ================= ACTION BUTTONS =================
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    icon: Icons.camera_alt,
                    label: "Open Camera",
                    onTap: _pickImageOptions,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _actionButton(
                    icon: Icons.upload_file,
                    label: "Upload PDF",
                    onTap: _pickPdf,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ================= UML FILE CARD =================
            if (selectedFile != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: softWhite,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 6),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file,
                        color: nectarGold),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName ?? "UML features to include.pdf",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: charcoal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Supported formats: PDF, JPG, PNG",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const Spacer(),

            // ================= PROCESS BUTTON =================
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: selectedFile == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProcessScreen(
                              file: selectedFile!,
                              fileName: fileName ?? "document",
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: deepHoney,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                child: const Text(
                  "Process Document",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "POWERED BY NECTAR AI",
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2,
                color: Colors.black26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= BUTTON WIDGET =================
  static Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: softWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: nectarGold),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: charcoal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}