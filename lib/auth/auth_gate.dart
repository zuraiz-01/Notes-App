import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test/pages/app_colors.dart';
import 'package:test/pages/home_page.dart';
import '../pages/login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // ⏳ While waiting for auth stream to connect
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.offWhite,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.accentOrange),
            ),
          );
        }

        // ✅ Extract session safely
        final session = snapshot.data?.session;

        // 👤 If user is logged in → go to HomePage
        if (session != null) {
          return const HomePage();
        }

        // 🚪 If not logged in → go to LoginPage
        return const LoginPage();
      },
    );
  }
}
