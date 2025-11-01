import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test/auth/auth_gate.dart';
import 'package:test/auth/global_loader.dart';
import 'package:test/auth/loading_provider.dart';
import 'package:provider/provider.dart';
import 'package:test/pages/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xcmlnqspnqyzwthobyrm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhjbWxucXNwbnF5end0aG9ieXJtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE2NDIyMTYsImV4cCI6MjA3NzIxODIxNn0.o8SQSKN-o2wre0O2fTV9dQ9paGcJgC-Q2NYsX9YElPo',
  );

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => LoadingProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.offWhite,
        colorScheme: const ColorScheme.light(
          primary: AppColors.accentOrange,
          secondary: AppColors.darkGrey,
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.almostBlack,
        ),
      ),
      home: GlobalLoader(child: const AuthGate()),
    );
  }
}
