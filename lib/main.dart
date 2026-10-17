import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nxnleneixjkbhybrkmaw.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54bmxlbmVpeGprYmh5YnJrbWF3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTEyNjU1MjgsImV4cCI6MjEwNjg0MTUyOH0.NfNc8sxMih6nQUAanfkXOLh5Sws7I6YYY4j8Nq00Vzk',
  );

  final session = Supabase.instance.client.auth.currentSession;

  runApp(QuickBiteApp(isLoggedIn: session != null));
}

class QuickBiteApp extends StatelessWidget {
  final bool isLoggedIn;
  const QuickBiteApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickBite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: isLoggedIn ? const MainNavigation() : const LoginScreen(),
    );
  }
}
