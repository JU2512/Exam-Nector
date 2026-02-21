import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'examnectar2026@gmail.com',
      query: 'subject=Support%20Request',
    );
    if (!await launchUrl(emailUri)) {
      throw 'Could not launch email';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'About Us',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            /// LOGO (SVG REPLACED – NOTHING ELSE CHANGED)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.yellow.withOpacity(0.2),
              ),
              child: Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? Colors.grey[850] : Colors.white,
                  ),
                  child: ClipOval(
  child: SvgPicture.asset(
    'assets/logo/logo.svg',
    fit: BoxFit.cover,
    allowDrawingOutsideViewBox: true,
  ),
),


                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'EXAM-NECTAR',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Paste, Process, Perform',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Making learning sweeter, one summary at a time.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 32),

            _infoCard(
              icon: Icons.rocket_launch,
              title: 'Our Mission',
              description:
                  'To empower students with smart learning tools that simplify complex information into digestible summaries, helping you achieve academic excellence without burnout.',
            ),

            const SizedBox(height: 32),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Key Features',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            const SizedBox(height: 16),

            _featureTile(
              icon: Icons.auto_awesome,
              title: 'Smart Summaries',
              subtitle: 'AI-driven extraction of core concepts.',
            ),
            _featureTile(
              icon: Icons.document_scanner,
              title: 'OCR Technology',
              subtitle: 'Scan physical notes and textbooks instantly.',
            ),
            _featureTile(
              icon: Icons.play_circle,
              title: 'YouTube Integration',
              subtitle: 'Turn long lectures into concise reading.',
            ),

            const SizedBox(height: 32),

            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuATw1lZ8yvwrObbjoGavhWoU7YDITihc2VKI2K4JC9maaGhe8McW8aXJppSZt7eaYehv_-6ed98Sd1mhYIbRd_2GxdMZcFyXtahi5bn2YPrMYl_fh_7ddOarNA8aq8ZsFAa-Xxl8P4N_u-JlycgyBWY_BoVrJVNcMPHRTRff9XU_Yx9E0eDr45lEQcCY6E1-IU48eHFmqYLPFu-KgTG-z0f-bIBvN1JEkp3mglMnPHYqYbCmopD54Oe4Rd-_vf3xv8uqoJnUAPwdxY',
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Our Story',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Exam-Nectar was born in a dorm room during finals week. We realized the challenge wasn’t lack of information—but too much of it.',
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 8),

            Text(
              'We help students “extract the nectar” — the pure, essential knowledge — from massive documents and videos.',
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 32),

            Divider(color: Colors.grey.shade300),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isDark ? Colors.grey[900] : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Have questions?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Our team is here to support your learning journey.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _launchEmail,
                      icon: const Icon(Icons.email),
                      label: const Text('Contact Us'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.lightBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              '© 2026 EXAM-NECTAR INC.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.amber.withOpacity(0.1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.amber, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.grey.withOpacity(0.08),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
