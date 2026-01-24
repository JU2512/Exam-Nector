import 'dart:io';
import 'package:flutter/material.dart';

// 🔗 IMPORT TARGET SCREENS
import '../scan_document/scan.dart';
import '../yt_link/yt_scan.dart';
import 'notification.dart';

// 🔗 BOTTOM NAV TARGETS
import 'package:exam_nector/features/library_screen/library.dart';
import '../fav_screen/favourite.dart';
import '../profile_screen/profile.dart';

// 🔑 STORAGE
import '../../core/user_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;
  int _currentIndex = 0;
  bool _isFabOpen = false;

  // 🔑 USER DATA
  String userName = "Guest";
  File? profileImage;

  // 🔔 NOTIFICATION
  int unreadCount = 5;

  final Color primary = const Color(0xFFF4B400);
  final Color primaryDark = const Color(0xFFE09F00);
  final Color primaryDeeper = const Color(0xFFD18C00);

  @override
  void initState() {
    super.initState();
    _loadUserFromStorage();
  }

  // ================= LOAD USER =================
  Future<void> _loadUserFromStorage() async {
    final data = await UserStorage.loadProfile();

    setState(() {
      userName = data["name"] ?? "Guest";
      if (data["image"] != null && data["image"]!.isNotEmpty) {
        profileImage = File(data["image"]!);
      } else {
        profileImage = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildHeader(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSlider(),
            const SizedBox(height: 28),
            _buildQuickActions(context),
            const SizedBox(height: 28),
            _buildLastActivity(),
          ],
        ),
      ),
      floatingActionButton: _buildExpandableFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ================= HEADER =================
  PreferredSizeWidget _buildHeader() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: profileImage != null
                  ? FileImage(profileImage!)
                  : const NetworkImage(
                      "https://ui-avatars.com/api/?name=Guest&background=F4B400&color=fff",
                    ) as ImageProvider,
            ),
            const SizedBox(width: 12),
            Text(
              "Welcome, $userName",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),

            // 🔔 NOTIFICATION
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                    setState(() => unreadCount = 0);
                  },
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= HERO SLIDER =================
  Widget _buildHeroSlider() {
    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            children: [
              _heroCard(
                "Ace Your Exams",
                "Get summarized notes instantly.",
                Icons.school,
              ),
              _heroCard(
                "Study Smart",
                "AI-powered summaries at your fingertips.",
                Icons.auto_awesome,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(2, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? primary
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _heroCard(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primaryDark, primaryDeeper],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              icon,
              size: 150,
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(subtitle,
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  // ================= QUICK ACTIONS =================
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Quick Actions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.72,
          ),
          children: [
            _QuickActionCard(
              title: "Scan Doc\nSummary",
              description: "Turn pages into\nconcise notes.",
              buttonText: "Scan Document",
              icon: Icons.document_scanner,
              accentColor: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ScanScreen(),
                  ),
                );
              },
            ),
            _QuickActionCard(
              title: "Video\nSummary",
              description: "Summarize YouTube\nvideos fast.",
              buttonText: "Paste Link",
              icon: Icons.play_circle_fill,
              accentColor: Colors.red,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const YtScanScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // ================= LAST ACTIVITY =================
  Widget _buildLastActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Last Activity",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.history_edu, color: Colors.orange),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Physics – Motion Summary",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= BOTTOM NAV =================
  Widget _buildBottomNav() {
    return BottomAppBar(
      notchMargin: 6,
      shape: const AutomaticNotchedShape(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
      ),
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navItem(Icons.home, "Home", 0),
            _navItem(Icons.library_books, "Library", 1),
            const SizedBox(width: 40),
            _navItem(Icons.star_border, "Saved", 2),
            _navItem(Icons.person_outline, "Profile", 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final bool selected = _currentIndex == index;

    return InkWell(
      onTap: () async {
        setState(() => _currentIndex = index);

        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LibraryApp()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FavouritesScreen()),
          );
        } else if (index == 3) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          );
          await _loadUserFromStorage();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? primary : Colors.grey),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: selected ? primary : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= EXPANDABLE FAB (RESTORED) =================
  Widget _buildExpandableFab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: SizedBox(
        width: 80,
        height: 240,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              bottom: _isFabOpen ? 78 : 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isFabOpen ? 1 : 0,
                child: Container(
                  width: 56,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 67, 65, 60),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Column(
                    children: [
                      _fabOption(
                        icon: Icons.document_scanner,
                        color: Colors.blue,
                        onTap: () {
                          setState(() => _isFabOpen = false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ScanScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      _fabOption(
                        icon: Icons.play_circle_fill,
                        color: Colors.red,
                        onTap: () {
                          setState(() => _isFabOpen = false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const YtScanScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            FloatingActionButton(
              backgroundColor: primary,
              onPressed: () {
                setState(() => _isFabOpen = !_isFabOpen);
              },
              child: AnimatedRotation(
                turns: _isFabOpen ? 0.125 : 0,
                duration: const Duration(milliseconds: 250),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fabOption({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
}

// ================= QUICK ACTION CARD =================
class _QuickActionCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.description,
    required this.buttonText,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            CircleAvatar(
              radius: 30,
              backgroundColor: accentColor.withOpacity(0.12),
              child: Icon(icon, color: accentColor, size: 32),
            ),
            Text(description,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600)),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(buttonText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
