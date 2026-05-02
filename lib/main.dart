import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fashion_store/firebase_options.dart';
import 'package:fashion_store/theme/app_theme.dart';
import 'package:fashion_store/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable performance optimizations
  // Reduce image cache size for better memory management
  PaintingBinding.instance.imageCache.maximumSize = 50;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50MB
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Load saved theme preference
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('darkMode') ?? false;
  AppTheme.setDarkMode(isDarkMode);
  
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
  bool _isDarkMode = AppTheme.isDarkMode;

  void _setTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDarkMode);
    AppTheme.setDarkMode(isDarkMode);
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
