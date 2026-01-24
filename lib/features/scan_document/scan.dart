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
  // ================= COLORS (UNCHANGED UI) =================
  static const Color warmCream = Color(0xFFFFF9ED);
  static const Color charcoalBlack = Color(0xFF1F2937);
  static const Color nectarGold = Color(0xFFF4B400);
  static const Color deepHoney = Color(0xFFE09F00);
  static const Color softWhite = Color(0xFFFFFFFF);

  File? selectedFile;
  String? fileName;

  final ImagePicker _picker = ImagePicker();

  // ================= CAMERA =================
  Future<void> openCamera() async {
    final permission = await Permission.camera.request();
    if (!permission.isGranted) return;

    final XFile? image =
        await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        selectedFile = File(image.path);
        fileName = image.name;
      });
    }
  }

  // ================= GALLERY =================
  Future<void> openGallery() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedFile = File(image.path);
        fileName = image.name;
      });
    }
  }

  // ================= IMAGE OPTIONS =================
  void pickImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading:
                    const Icon(Icons.camera_alt, color: nectarGold),
                title: const Text("Take Photo"),
                onTap: () {
                  Navigator.pop(context);
                  openCamera();
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: nectarGold),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  openGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= PDF PICK =================
  Future<void> pickPdf() async {
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
      appBar: AppBar(
        backgroundColor: warmCream,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: charcoalBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Scan Document",
          style: TextStyle(
            color: charcoalBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            // ================= SCAN CARD =================
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [softWhite, warmCream],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: nectarGold, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8),
                ],
              ),
              child: Column(
                children: const [
                  Icon(Icons.photo_camera,
                      size: 48, color: nectarGold),
                  SizedBox(height: 16),
                  Text(
                    "Tap to Scan or Upload",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: charcoalBlack,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Place your document within the frame to scan automatically",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ================= ACTION BUTTONS =================
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    icon: Icons.camera_alt,
                    label: "Upload Image",
                    onTap: pickImageOptions, // ✅ UPDATED
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _actionButton(
                    icon: Icons.upload_file,
                    label: "Upload PDF",
                    onTap: pickPdf,
                  ),
                ),
              ],
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
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  // ================= BUTTON =================
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
                color: charcoalBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}