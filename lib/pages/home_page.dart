import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test/pages/login_page.dart';
import 'package:test/pages/notes_page.dart';
import 'package:test/pages/profile_page.dart';
import 'package:test/services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 1;

  final pages = const [ProfilePage(), NotesPage()];

  void _onItemTapped(int index) {
    setState(() => selectedIndex = index);
  }

  // Future<void> _logout() async {
  //   try {
  //     await Supabase.instance.client.auth.signOut();
  //     if (!mounted) return;
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       if (!mounted) return;
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => const LoginPage()),
  //       );
  //     });
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
  //     }
  //   }
  // }
  Future<void> _logout() async {
    try {
      // 🔔 Notify user logout started
      await NotificationService().showNotification(
        id: 6,
        title: "Logging Out",
        body: "You are being logged out...",
      );

      await Supabase.instance.client.auth.signOut();

      // 🔔 Notify user logout success
      await NotificationService().showNotification(
        id: 7,
        title: "Logged Out Successfully",
        body: "You have been signed out of your account.",
      );

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));

        // 🔔 Notify user logout failure
        await NotificationService().showNotification(
          id: 8,
          title: "Logout Failed",
          body: "There was an issue signing you out. Please try again.",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final Color background = const Color(0xFFF5F6FA); // soft light gray
    final Color accent = const Color(0xFF9C8EF3); // soft lavender purple

    return Scaffold(
      backgroundColor: background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedIndex == 0 ? "Profile" : "Notes",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.logout_rounded, color: accent, size: 26),
                  tooltip: "Logout",
                  onPressed: _logout,
                ),
              ],
            ),
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: IndexedStack(
          key: ValueKey<int>(selectedIndex),
          index: selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: accent,
            unselectedItemColor: Colors.grey.shade500,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.note_alt_outlined),
                activeIcon: Icon(Icons.note_alt),
                label: 'Notes',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
