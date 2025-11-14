import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rosegoldsmith/screens/home_screen.dart';
import 'package:rosegoldsmith/theme.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rosegoldsmith Jewelry Inventory',
      theme: AppTheme.themeData,
      home: const HomeScreen(),
    );
  }
}
