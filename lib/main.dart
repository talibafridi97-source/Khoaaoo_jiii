import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase Initialized with your project reference (nxnleneixjkbhybrkmaw)
  await Supabase.initialize(
    url: 'https://nxnleneixjkbhybrkmaw.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54bmxlbmVpeGprYmh5YnJrbWF3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTEyNjU1MjgsImV4cCI6MjEwNjg0MTUyOH0.NfNc8sxMih6nQUAanfkXOLh5Sws7I6YYY4j8Nq00Vzk', // TODO: Paste your long JWT anon/public key here from Supabase API settings
  );

  runApp(const QuickBiteApp());
}

class QuickBiteApp extends StatelessWidget {
  const QuickBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickBite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
