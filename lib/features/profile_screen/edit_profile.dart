import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  // 🎨 EXACT COLORS (UNCHANGED)
  static const Color nectarGold = Color(0xFFF4B400);
  static const Color warmCream = Color(0xFFFFF9ED);
  static const Color charcoal = Color(0xFF1F2937);

  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();

  File? profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // 🔄 LOAD SAVED DATA
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString('name') ?? 'Sushant Kumar';
      usernameController.text =
          prefs.getString('username') ?? 'alex_nectar';
      emailController.text =
          prefs.getString('email') ?? 'alex@studybuzz.edu';
      bioController.text = prefs.getString('bio') ?? 'Smart Learner';

      final img = prefs.getString('image');
      if (img != null && img.isNotEmpty) {
        profileImage = File(img);
      }
    });
  }

  // 🖼 IMAGE PICK
  Future<void> _pickImage() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() {
        profileImage = File(picked.path);
      });
    }
  }

  // 💾 SAVE DATA
  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('name', nameController.text.trim());
    await prefs.setString('username', usernameController.text.trim());
    await prefs.setString('email', emailController.text.trim());
    await prefs.setString('bio', bioController.text.trim());

    if (profileImage != null) {
      await prefs.setString('image', profileImage!.path);
    }

    // 🔙 RETURN TRUE SO PROFILE PAGE REFRESHES
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warmCream,
      appBar: AppBar(
        backgroundColor: warmCream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: nectarGold),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Update Profile",
          style: TextStyle(
            color: charcoal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24).copyWith(bottom: 140),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // 👤 PROFILE IMAGE (SAME UI)
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 65,
                      backgroundColor: nectarGold,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: profileImage != null
                            ? FileImage(profileImage!)
                            : const NetworkImage(
                                "https://ui-avatars.com/api/?name=User",
                              ) as ImageProvider,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: const CircleAvatar(
                          radius: 22,
                          backgroundColor: nectarGold,
                          child: Icon(
                            Icons.add_a_photo,
                            color: charcoal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                _inputField("Full Name", nameController),
                _inputField("Username", usernameController),
                _inputField("Bio / Status", bioController),
                _inputField("Email Address", emailController),
              ],
            ),
          ),

          // 💛 SAVE BUTTON (BOTTOM FIXED)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: nectarGold,
                  foregroundColor: charcoal,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  "SAVE CHANGES",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✏️ INPUT FIELD (UNCHANGED UI)
  Widget _inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: charcoal,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}