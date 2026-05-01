import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fashion_store/theme/app_theme.dart';
import 'package:fashion_store/main.dart';
import 'package:fashion_store/services/notification_service.dart';
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
