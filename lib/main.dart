import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';


Future<void> main() async {
  await Supabase.initialize(
    url: 'https://etyutxvbuosvopeiftgo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV0eXV0eHZidW9zdm9wZWlmdGdvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg3MTY0ODEsImV4cCI6MjA1NDI5MjQ4MX0.hsYCtaOWuITxQBKnt6k0IktdO788WA-MwXlJq6CuXSw',
  );
  runApp(MyApp());
}
        

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      title: 'kasir',
      home: LoginPage(), // LoginPage
    );
  }
}
