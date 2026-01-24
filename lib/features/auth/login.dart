import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

// 🔗 TARGET SCREENS
import 'register.dart';
import 'package:exam_nector/features/home_screen/home.dart'; // ✅ UPDATE PATH IF NEEDED

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;

  Future<void> _login() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnack("Please fill all fields");
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // ✅ SUCCESS → GO TO HOME
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
        (route) => false, // 🔥 clears login stack
      );
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? "Login failed");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9ED),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "Welcome Back",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 40),

                _buildInput(
                  controller: _emailController,
                  hint: "Email",
                  icon: Icons.email,
                  obscure: false,
                ),
                const SizedBox(height: 20),

                _buildInput(
                  controller: _passwordController,
                  hint: "Password",
                  icon: Icons.lock,
                  obscure: _obscurePassword,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 30),

                GestureDetector(
                  onTap: _loading ? null : _login,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4B400),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: _loading
                          ? const CircularProgressIndicator(
                              color: Colors.black,
                            )
                          : Text(
                              "Login",
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 🔁 NAVIGATE TO REGISTER
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don’t have an account?",
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Sign up",
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFF4B400),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool obscure,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          suffixIcon: suffix,
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}