import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fashion_store/firebase_options.dart';
import 'package:fashion_store/theme/app_theme.dart';
import 'package:fashion_store/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const TrendifyApp());
}

class TrendifyApp extends StatefulWidget {
  const TrendifyApp({super.key});

  static void setTheme(BuildContext context, bool isDarkMode) {
    final _TrendifyAppState? state = context.findAncestorStateOfType<_TrendifyAppState>();
    state?._setTheme(isDarkMode);
  }

  @override
  State<TrendifyApp> createState() => _TrendifyAppState();
}

class _TrendifyAppState extends State<TrendifyApp> {
  bool _isDarkMode = false;

  void _setTheme(bool isDarkMode) {
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TRENDIFY',
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
