import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test/auth/auth_service.dart';
import 'package:test/pages/home_page.dart';
import 'package:test/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  Future<void> _login() async {
    if (!mounted) return;
    setState(() => loading = true);

    try {
      final response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response.session != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        });
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bg = const Color(0xFFF5F6FA);
    final Color card = Colors.white;
    final Color accent = const Color(0xFF9C8EF3); // same as ProfilePage
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
                  // ignore: deprecated_member_use
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
                  // ignore: deprecated_member_use
                  backgroundColor: accent.withOpacity(0.15),
                  child: const Icon(
                    Icons.note_alt_rounded,
                    color: Color(0xFF9C8EF3),
                    size: 38,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Welcome Back 👋',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: isMobile ? 22 : 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Login to your Notes account',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: isMobile ? 14 : 15,
                  ),
                ),

                const SizedBox(height: 32),

                // Email Field
                _inputField(
                  controller: emailController,
                  hint: "Email address",
                  icon: Icons.email_outlined,
                  accent: accent,
                ),

                const SizedBox(height: 18),

                // Password Field
                _inputField(
                  controller: passwordController,
                  hint: "Password",
                  icon: Icons.lock_outline_rounded,
                  accent: accent,
                  obscureText: true,
                ),

                const SizedBox(height: 28),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                    ),
                    child: loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 22),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.grey.shade400, thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.grey.shade400, thickness: 1),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Google Sign In
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      StreamSubscription<AuthState>? authSub;

                      try {
                        final authService = AuthService();
                        await authService.signInWithGoogle();

                        authSub = Supabase
                            .instance
                            .client
                            .auth
                            .onAuthStateChange
                            .listen((event) {
                              final session = event.session;
                              if (session != null && context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HomePage(),
                                  ),
                                );
                              }
                            });
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Google sign-in failed: $e'),
                            ),
                          );
                        }
                      }

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        authSub?.cancel();
                      });
                    },
                    icon: Image.asset(
                      'assets/google_icon.jpeg',
                      height: 24,
                      width: 24,
                    ),
                    label: const Text(
                      'Sign in with Google',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        // ignore: deprecated_member_use
                        color: accent.withOpacity(0.6),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                // Footer
                GestureDetector(
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  ),
                  child: Text(
                    "New to Notes? Sign up here",
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

  // Reusable Input Field Widget
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
