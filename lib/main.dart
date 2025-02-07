import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://xjuyhanatygalppwsuin.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhqdXloYW5hdHlnYWxwcHdzdWluIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYxMzg4MDAsImV4cCI6MjA1MTcxNDgwMH0.Bey38BukX4jX5pL5vQbkFNhqD8ltFr_q7SB6h-b4TLI',
    );
    runApp(MyApp());
  } catch (e) {
    print('Error initializing Supabase: $e');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'kasir',
      home: LoginPage(), // LoginPage
    );
  }
}
