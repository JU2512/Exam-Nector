import 'dart:io';
import 'package:flutter/material.dart';

import 'edit_profile.dart';
import 'feedback.dart';
import 'about.dart';
import '../home_screen/home.dart';
import '../../core/user_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? profileImage;
  String name = "Sushant Kumar";
  String bio = "Smart Learner";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ================= LOAD DATA =================
  Future<void> _loadProfile() async {
    final data = await UserStorage.loadProfile();

    setState(() {
  name = data["name"] ?? name;
  bio = data["bio"] ?? bio;

  final String? imagePath = data["image"] as String?;

  profileImage = (imagePath != null && imagePath.isNotEmpty)
      ? File(imagePath)
      : null;
});

  }

  // ================= SIGN OUT =================
  Future<void> _handleSignOut() async {
    await UserStorage.clear();

    Navigator.of(context)
      ..pop()
      ..pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBEF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Profile Page',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ================= PROFILE IMAGE =================
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber, width: 4),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: profileImage != null
                      ? FileImage(profileImage!)
                      : const NetworkImage(
                          'https://ui-avatars.com/api/?name=User&background=F4B400&color=fff',
                        ) as ImageProvider,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ================= NAME =================
            Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            // ❌ GREEN LINE REMOVED HERE ❌

            const SizedBox(height: 6),

            Text(
              bio,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // ================= EDIT PROFILE =================
            OutlinedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UpdateProfilePage(),
                  ),
                );

                _loadProfile(); // reload after edit
              },
              style: OutlinedButton.styleFrom(
                shape: const StadiumBorder(),
                side: const BorderSide(color: Colors.amber),
              ),
              child: const Text("Edit Profile"),
            ),

            const SizedBox(height: 28),

            // ================= STATS SECTION (ADDED) =================
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: const [
                  Expanded(
                    child: _StatItem(
                      icon: Icons.description,
                      color: Colors.blue,
                      count: "45",
                      label: "Scan",
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: VerticalDivider(thickness: 1),
                  ),
                  Expanded(
                    child: _StatItem(
                      icon: Icons.play_circle_fill,
                      color: Colors.red,
                      count: "18",
                      label: "Video",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ================= SUPPORT =================
            const _SectionTitle(title: "Support"),
            _MenuTile(
              icon: Icons.rate_review,
              title: "Share feedback",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FeedbackScreen()),
              ),
            ),
            _MenuTile(
              icon: Icons.info,
              title: "About Us",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutUsPage()),
              ),
            ),

            const SizedBox(height: 20),

            // ================= MORE =================
            const _SectionTitle(title: "More"),
            _MenuTile(
              icon: Icons.logout,
              title: "Sign out",
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) =>
                      SignOutDialog(onConfirm: _handleSignOut),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ================= STATS ITEM =================
class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String count;
  final String label;

  const _StatItem({
    required this.icon,
    required this.color,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          "$count $label",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ================= SIGN OUT DIALOG (UNCHANGED) =================
class SignOutDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  const SignOutDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3D6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout,
                  color: Color(0xFFF4B400), size: 30),
            ),
            const SizedBox(height: 20),
            const Text("Sign Out",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              "You can always sign back in to access\nyour summaries and saved notes.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF4B400),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: onConfirm,
                child: const Text("Sign Out",
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Stay Logged In"),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= HELPERS =================
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: Icon(icon, size: 18, color: Colors.grey.shade700),
        ),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}