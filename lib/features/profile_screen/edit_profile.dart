import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/user_storage.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  // Colors (UNCHANGED)
  static const Color nectarGold = Color(0xFFF4B400);
  static const Color warmCream = Color(0xFFFFF9ED);
  static const Color charcoal = Color(0xFF1F2937);
  static const Color warmGrey = Color(0xFF6B7280);

  // 🔑 CONTROLLERS
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // 🖼 PROFILE IMAGE
  File? profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadFromStorage();
  }

  // ================= LOAD EXISTING DATA =================
  Future<void> _loadFromStorage() async {
    final data = await UserStorage.loadProfile();

    setState(() {
      nameController.text = data["name"] ?? "Sushant Kumar";
      bioController.text = data["bio"] ?? "Smart Learner";
      usernameController.text = "alex_nectar"; // UI-only
      emailController.text = "alex@studybuzz.edu"; // UI-only

      if (data["image"] != null && data["image"]!.isNotEmpty) {
        profileImage = File(data["image"]!);
      }
    });
  }

  // ================= IMAGE PICK =================
  Future<void> _pickImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image != null) {
      setState(() {
        profileImage = File(image.path);
      });
    }
  }

  // ================= SAVE (🔥 FIXED) =================
  Future<void> _saveChanges() async {
    await UserStorage.saveProfile(
      name: nameController.text.trim(),
      bio: bioController.text.trim(),
      imagePath: profileImage?.path,
    );

    Navigator.pop(context); // Profile & Home will reload
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warmCream,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: warmCream.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: nectarGold),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Update Profile Details",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: charcoal,
          ),
        ),
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24)
                .copyWith(top: 24, bottom: 180),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // ================= PROFILE IMAGE (UNCHANGED UI) =================
                Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: nectarGold, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          )
                        ],
                      ),
                      child: ClipOval(
                        child: profileImage != null
                            ? Image.file(profileImage!, fit: BoxFit.cover)
                            : const Image(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                  "https://ui-avatars.com/api/?name=User&background=F4B400&color=fff",
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: nectarGold,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.add_a_photo,
                            size: 20,
                            color: charcoal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                buildInputField(
                  label: "Full Name",
                  hint: "Enter your full name",
                  controller: nameController,
                ),
                const SizedBox(height: 20),

                buildUsernameField(),
                const SizedBox(height: 20),

                buildBioField(),
                const SizedBox(height: 20),

                buildInputField(
                  label: "Email Address",
                  hint: "yourname@example.com",
                  controller: emailController,
                ),
              ],
            ),
          ),

          // ================= SAVE BUTTON =================
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    warmCream,
                    warmCream.withOpacity(0.7),
                    warmCream.withOpacity(0),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: ElevatedButton(
                onPressed: _saveChanges,
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
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= INPUT HELPERS (UNCHANGED) =================
  Widget buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 6),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: charcoal)),
        ),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            border: borderStyle(),
            enabledBorder: borderStyle(),
            focusedBorder: borderStyleFocused(),
          ),
        ),
      ],
    );
  }

  Widget buildUsernameField() => buildInputField(
        label: "Username",
        hint: "username",
        controller: usernameController,
      );

  Widget buildBioField() => buildInputField(
        label: "Bio / Status",
        hint: "Tell something about yourself",
        controller: bioController,
      );

  static OutlineInputBorder borderStyle() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      );

  static OutlineInputBorder borderStyleFocused() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: nectarGold, width: 2),
      );
}
