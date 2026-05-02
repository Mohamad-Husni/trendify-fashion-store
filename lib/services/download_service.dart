import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DownloadService {
  static const String _githubRepo = 'https://github.com/Mohamad-Husni/trendify-fashion-store';
  static const String _webAppUrl = 'https://trendify-fashion-store.web.app';

  static Future<bool> downloadForPlatform(String platform) async {
    try {
      switch (platform.toLowerCase()) {
        case 'android':
          return await _downloadAndroid();
        case 'ios':
          return await _downloadiOS();
        case 'windows':
          return await _downloadWindows();
        case 'macos':
          return await _downloadMacOS();
        case 'web':
          return await _openWebApp();
        default:
          return false;
      }
    } catch (e) {
      debugPrint('Download error for $platform: $e');
      return false;
    }
  }

  static Future<bool> _downloadAndroid() async {
    // For Android, direct to APK file or GitHub releases
    final apkUrl = '$_githubRepo/releases/download/v1.0.0/trendify-android.apk';
    
    if (kIsWeb) {
      // On web, open GitHub releases page
      return await launchUrl(Uri.parse('$_githubRepo/releases'));
    } else {
      // On mobile, try to download APK
      return await launchUrl(Uri.parse(apkUrl), mode: LaunchMode.externalApplication);
    }
  }

  static Future<bool> _downloadiOS() async {
    // For iOS, direct to GitHub releases (IPA files require TestFlight or sideloading)
    return await launchUrl(Uri.parse('$_githubRepo/releases'));
  }

  static Future<bool> _downloadWindows() async {
    // For Windows, direct to GitHub releases
    final exeUrl = '$_githubRepo/releases/download/v1.0.0/trendify-windows.exe';
    
    if (kIsWeb) {
      return await launchUrl(Uri.parse('$_githubRepo/releases'));
    } else {
      return await launchUrl(Uri.parse(exeUrl), mode: LaunchMode.externalApplication);
    }
  }

  static Future<bool> _downloadMacOS() async {
    // For macOS, direct to GitHub releases
    final dmgUrl = '$_githubRepo/releases/download/v1.0.0/trendify-macos.dmg';
    
    if (kIsWeb) {
      return await launchUrl(Uri.parse('$_githubRepo/releases'));
    } else {
      return await launchUrl(Uri.parse(dmgUrl), mode: LaunchMode.externalApplication);
    }
  }

  static Future<bool> _openWebApp() async {
    return await launchUrl(Uri.parse(_webAppUrl));
  }

  static String getDownloadInfo(String platform) {
    switch (platform.toLowerCase()) {
      case 'android':
        return 'APK file for Android 5.0+ (API 21+)\nSize: ~52 MB\nInstallation: Enable "Unknown Sources" in settings';
      case 'ios':
        return 'IPA file for iOS 12.0+\nSize: ~58 MB\nInstallation: Requires TestFlight or sideloading';
      case 'windows':
        return 'EXE installer for Windows 10/11\nSize: ~65 MB\nInstallation: Run installer as administrator';
      case 'macos':
        return 'DMG file for macOS 10.14+\nSize: ~62 MB\nInstallation: Open DMG and drag to Applications';
      case 'web':
        return 'Web application\nWorks on all modern browsers\nNo installation required';
      default:
        return 'Platform not supported';
    }
  }

  static String getDownloadStatus(String platform) {
    switch (platform.toLowerCase()) {
      case 'android':
        return 'Available';
      case 'ios':
        return 'Available';
      case 'windows':
        return 'Coming Soon';
      case 'macos':
        return 'Coming Soon';
      case 'web':
        return 'Live';
      default:
        return 'Not Available';
    }
  }

  static bool isDownloadAvailable(String platform) {
    final status = getDownloadStatus(platform);
    return status == 'Available' || status == 'Live';
  }
}
