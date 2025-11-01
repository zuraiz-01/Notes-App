import 'package:flutter/material.dart';
import 'package:test/auth/auth_service.dart';
import 'package:test/pages/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final authService = AuthService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords don't match")),
      );
      return;
    }

    try {
      await authService.signUpWithEmailPassword(email, password);

      if (!mounted) return;

      // ✅ After signup, go to Login Page instead of popping
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account created successfully! Please log in.")),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color bg = const Color(0xFFF5F6FA);
    final Color card = Colors.white;
    final Color accent = const Color(0xFF9C8EF3);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : size.width * 0.25,
            vertical: isMobile ? 24 : 50,
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 430),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 36,
              vertical: isMobile ? 36 : 48,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App Icon
                CircleAvatar(
                  radius: 36,
                  backgroundColor: accent.withOpacity(0.15),
                  child: const Icon(
                    Icons.person_add_alt_1_rounded,
                    color: Color(0xFF9C8EF3),
                    size: 38,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Create Account ✨',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: isMobile ? 22 : 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sign up to start using Notes',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: isMobile ? 14 : 15,
                  ),
                ),

                const SizedBox(height: 32),

                // Email Field
                _inputField(
                  controller: _emailController,
                  hint: "Email address",
                  icon: Icons.email_outlined,
                  accent: accent,
                ),
                const SizedBox(height: 18),

                // Password Field
                _inputField(
                  controller: _passwordController,
                  hint: "Password",
                  icon: Icons.lock_outline_rounded,
                  accent: accent,
                  obscureText: true,
                ),
                const SizedBox(height: 18),

                // Confirm Password Field
                _inputField(
                  controller: _confirmPasswordController,
                  hint: "Confirm Password",
                  icon: Icons.lock_reset_rounded,
                  accent: accent,
                  obscureText: true,
                ),

                const SizedBox(height: 30),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                // Footer
                GestureDetector(
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  ),
                  child: Text(
                    "Already have an account? Log in",
                    style: TextStyle(
                      color: accent,
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Reusable Input Field Widget
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color accent,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF0F1F5),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade600),
        prefixIcon: Icon(icon, color: accent),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
