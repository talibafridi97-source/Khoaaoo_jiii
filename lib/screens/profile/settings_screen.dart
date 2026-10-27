import 'package:flutter/material.dart';
import '../../services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ThemeService _themeService = ThemeService();
  bool _pushNotifications = true;
  bool _emailAlerts = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Settings & Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Preferences', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode, color: Colors.deepOrange),
                  title: const Text('Dark Mode Theme', style: TextStyle(fontWeight: FontWeight.bold)),
                  value: _themeService.isDarkMode,
                  activeColor: Colors.deepOrange,
                  onChanged: (val) {
                    setState(() {
                      _themeService.toggleTheme(val);
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications, color: Colors.deepOrange),
                  title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Receive order status updates live'),
                  value: _pushNotifications,
                  activeColor: Colors.deepOrange,
                  onChanged: (val) {
                    setState(() {
                      _pushNotifications = val;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.email, color: Colors.deepOrange),
                  title: const Text('Email Alerts', style: TextStyle(fontWeight: FontWeight.bold)),
                  value: _emailAlerts,
                  activeColor: Colors.deepOrange,
                  onChanged: (val) {
                    setState(() {
                      _emailAlerts = val;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('About Khoaaoo_jiii', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info, color: Colors.deepOrange),
                  title: const Text('App Version', style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Text('1.0.0+1', style: TextStyle(color: Colors.grey)),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip, color: Colors.deepOrange),
                  title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Privacy Policy links to web')));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
