import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/main_navigation.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nxnleneixjkbhybrkmaw.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54bmxlbmVpeGprYmh5YnJrbWF3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTEyNjU1MjgsImV4cCI6MjEwNjg0MTUyOH0.NfNc8sxMih6nQUAanfkXOLh5Sws7I6YYY4j8Nq00Vzk',
  );

  final session = Supabase.instance.client.auth.currentSession;

  runApp(QuickBiteApp(isLoggedIn: session != null));
}

class QuickBiteApp extends StatefulWidget {
  final bool isLoggedIn;
  const QuickBiteApp({super.key, required this.isLoggedIn});

  @override
  State<QuickBiteApp> createState() => _QuickBiteAppState();
}

class _QuickBiteAppState extends State<QuickBiteApp> {
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _themeService.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Khoaaoo_jiii',
      debugShowCheckedModeBanner: false,
      themeMode: _themeService.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: widget.isLoggedIn ? const MainNavigation() : const LoginScreen(),
    );
  }
}
