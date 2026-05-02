import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fashion_store/theme/app_theme.dart';
import 'package:fashion_store/main.dart';
import 'package:fashion_store/services/notification_service.dart';
import 'package:fashion_store/services/download_service.dart';
import 'package:fashion_store/screens/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _auth = FirebaseAuth.instance;
  final _notificationService = NotificationService();
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'INR (₹)';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = _notificationService.notificationsEnabled;
      _darkMode = prefs.getBool('darkMode') ?? false;
      _selectedLanguage = prefs.getString('language') ?? 'English';
      _selectedCurrency = prefs.getString('currency') ?? 'INR (₹)';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.darkBg : Colors.white;
    final textColor = isDark ? Colors.white : AppTheme.deepBlack;
    final iconColor = isDark ? Colors.white : AppTheme.deepBlack;
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SETTINGS',
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSectionTitle('ACCOUNT', color: isDark ? Colors.grey : Colors.grey[600]),
            _buildSettingsTile(
              Icons.lock_outline,
              'Change Password',
              iconColor: iconColor,
              onTap: () => _showChangePasswordDialog(),
            ),
            const Divider(height: 32),

            // Notifications Section
            _buildSectionTitle('NOTIFICATIONS', color: isDark ? Colors.grey : Colors.grey[600]),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Push Notifications', style: TextStyle(color: textColor)),
              subtitle: Text('Receive order updates and offers', style: TextStyle(color: isDark ? Colors.grey : Colors.grey[600])),
              value: _notificationsEnabled,
              activeColor: AppTheme.gold,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                _notificationService.setNotificationsEnabled(value);
              },
            ),
            const Divider(height: 32),

            // Preferences Section
            _buildSectionTitle('PREFERENCES', color: isDark ? Colors.grey : Colors.grey[600]),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Dark Mode', style: TextStyle(color: textColor)),
              subtitle: Text('Enable dark theme', style: TextStyle(color: isDark ? Colors.grey : Colors.grey[600])),
              value: _darkMode,
              activeColor: AppTheme.gold,
              onChanged: (value) async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('darkMode', value);
                setState(() {
                  _darkMode = value;
                });
                // Apply theme immediately
                TrendifyApp.setTheme(context, value);
              },
            ),
            const Divider(height: 32),

            // Download Apps Section
            _buildSectionTitle('DOWNLOAD APPS', color: isDark ? Colors.grey : Colors.grey[600]),
            _buildDownloadSection(isDark, textColor),
            const Divider(height: 32),

            // About Section
            _buildSectionTitle('ABOUT', color: isDark ? Colors.grey : Colors.grey[600]),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.info_outline, color: iconColor),
              title: Text('App Version', style: TextStyle(color: textColor)),
              subtitle: Text('1.0.0', style: TextStyle(color: isDark ? Colors.grey : Colors.grey[600])),
            ),
            const Divider(height: 32),

            // Danger Zone
            _buildSectionTitle('DANGER ZONE', color: Colors.red),
            _buildSettingsTile(
              Icons.logout,
              'Logout',
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () => _showLogoutConfirm(),
            ),
            _buildSettingsTile(
              Icons.delete_forever,
              'Delete Account',
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () => _showDeleteAccountConfirm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
          color: color ?? Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, {Color? textColor, Color? iconColor, VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor ?? (isDark ? Colors.white : AppTheme.deepBlack)),
      title: Text(
        title,
        style: TextStyle(color: textColor ?? (isDark ? Colors.white : AppTheme.deepBlack)),
      ),
      trailing: onTap != null
          ? Icon(Icons.arrow_forward_ios, size: 16, color: textColor ?? Colors.grey)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildDownloadSection(bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Get Trendify on all your devices',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildDownloadButton(
                'Android',
                Icons.android,
                'APK',
                () => _downloadApp('android'),
                isDark: isDark,
                isAvailable: DownloadService.isDownloadAvailable('android'),
                status: DownloadService.getDownloadStatus('android'),
              ),
              _buildDownloadButton(
                'iOS',
                Icons.phone_iphone,
                'IPA',
                () => _downloadApp('ios'),
                isDark: isDark,
                isAvailable: DownloadService.isDownloadAvailable('ios'),
                status: DownloadService.getDownloadStatus('ios'),
              ),
              _buildDownloadButton(
                'Windows',
                Icons.computer,
                'EXE',
                () => _downloadApp('windows'),
                isDark: isDark,
                isAvailable: DownloadService.isDownloadAvailable('windows'),
                status: DownloadService.getDownloadStatus('windows'),
              ),
              _buildDownloadButton(
                'macOS',
                Icons.laptop_mac,
                'DMG',
                () => _downloadApp('macos'),
                isDark: isDark,
                isAvailable: DownloadService.isDownloadAvailable('macos'),
                status: DownloadService.getDownloadStatus('macos'),
              ),
              _buildDownloadButton(
                'Web App',
                Icons.language,
                'LIVE',
                () => _downloadApp('web'),
                isDark: isDark,
                isAvailable: DownloadService.isDownloadAvailable('web'),
                status: DownloadService.getDownloadStatus('web'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Android: APK file for manual installation\n• iOS: IPA file for TestFlight/Sideload\n• Windows: Installer for Windows 10/11\n• macOS: DMG file for macOS 10.14+',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(
    String platform,
    IconData icon,
    String format,
    VoidCallback onTap, {
    bool isDark = false,
    bool isAvailable = true,
    String status = 'Available',
  }) {
    return InkWell(
      onTap: isAvailable ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: status == 'Live' ? AppTheme.gold : 
                   isAvailable ? (isDark ? Colors.grey[700]! : Colors.grey[300]!) :
                   Colors.grey.withOpacity(0.3),
          ),
          boxShadow: status == 'Live' ? [
            BoxShadow(
              color: AppTheme.gold.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            )
          ] : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: status == 'Live' ? AppTheme.gold :
                     isAvailable ? (isDark ? Colors.white : AppTheme.deepBlack) :
                     Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              platform,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: status == 'Live' ? AppTheme.gold :
                       isAvailable ? (isDark ? Colors.white : AppTheme.deepBlack) :
                       Colors.grey,
              ),
            ),
            Text(
              format,
              style: TextStyle(
                fontSize: 10,
                color: status == 'Live' ? AppTheme.gold :
                       isAvailable ? (isDark ? Colors.grey[400] : Colors.grey[600]) :
                       Colors.grey,
                fontWeight: status == 'Live' ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (status == 'Coming Soon')
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'SOON',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _downloadApp(String platform) async {
    final isAvailable = DownloadService.isDownloadAvailable(platform);
    final status = DownloadService.getDownloadStatus(platform);
    
    if (!isAvailable && status != 'Live') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$platform app is $status'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (status == 'Live' && platform == 'web') {
      // For web app, directly open
      final success = await DownloadService.downloadForPlatform(platform);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening web app...'),
            backgroundColor: AppTheme.gold,
          ),
        );
      }
      return;
    }

    // Show download info dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Download $platform App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Platform: $platform'),
            const SizedBox(height: 8),
            Text('Version: 1.0.0'),
            const SizedBox(height: 8),
            Text('Status: $status'),
            const SizedBox(height: 16),
            Text(
              DownloadService.getDownloadInfo(platform),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          if (isAvailable)
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final success = await DownloadService.downloadForPlatform(platform);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? 'Download started for $platform...' : 
                               'Failed to start download for $platform'
                      ),
                      backgroundColor: success ? AppTheme.gold : Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: Colors.black,
              ),
              child: Text(status == 'Live' ? 'OPEN' : 'DOWNLOAD'),
            ),
        ],
      ),
    );
  }

  String _getAppSize(String platform) {
    switch (platform) {
      case 'android':
        return '15 MB';
      case 'ios':
        return '18 MB';
      case 'windows':
        return '25 MB';
      case 'macos':
        return '22 MB';
      default:
        return '20 MB';
    }
  }

  void _showLanguageSelector() {
    final languages = ['English', 'Hindi', 'Tamil', 'Telugu', 'Kannada', 'Malayalam'];
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...languages.map((lang) => ListTile(
                title: Text(lang),
                trailing: _selectedLanguage == lang
                    ? const Icon(Icons.check, color: AppTheme.gold)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedLanguage = lang;
                  });
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  void _showCurrencySelector() {
    final currencies = ['INR (₹)', r'USD ($)', 'EUR (€)', 'GBP (£)'];
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Select Currency',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...currencies.map((curr) => ListTile(
                title: Text(curr),
                trailing: _selectedCurrency == curr
                    ? const Icon(Icons.check, color: AppTheme.gold)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedCurrency = curr;
                  });
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password changed successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('CHANGE'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _auth.signOut();
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('LOGOUT'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
        content: const Text(
          'This action cannot be undone. All your data including orders, addresses, and wishlist will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion request submitted'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
}
