// settings_screen.dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false; // 🌙 Light by default
  bool _cloudBackupEnabled = false; // 🛡️ Placeholder for future

  // 🛠️ Method to toggle themes (will be wired later if needed)
  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    // Future: Here you would notify app theme controller
  }

  // 🛠️ Placeholder for clearing all cards (to be wired later)
  void _clearAllCards() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Are you sure you want to delete all saved cards? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🗑️ All cards cleared (placeholder action).')),
              );
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance section
          const Text('Appearance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Dark Mode (Coming Soon)'),
            value: _isDarkMode,
            onChanged: (val) => _toggleTheme(val),
          ),
          const Divider(height: 32),

          // Manage Data
          const Text('Manage Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Clear All Saved Cards'),
            onTap: _clearAllCards,
          ),
          const Divider(height: 32),

          // Cloud Backup (future)
          const Text('Cloud Backup', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Enable Cloud Backup (Coming Soon)'),
            value: _cloudBackupEnabled,
            onChanged: (val) {
              setState(() {
                _cloudBackupEnabled = val;
              });
            },
          ),
          const Divider(height: 32),

          // About App Section
          const Text('App Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          // ✅ Replaced: About CardReader tile to navigate to About screen
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About CardReader'),
            onTap: () {
              Navigator.pushNamed(context, '/about'); // ✅ Navigate to AboutScreen
            },
          ),

          // ✅ Replaced: Privacy Policy tile to navigate to Privacy Policy screen
          ListTile(
            leading: const Icon(Icons.shield),
            title: const Text('Privacy Policy'),
            onTap: () {
              Navigator.pushNamed(context, '/privacy-policy'); // ✅ Navigate to PrivacyPolicyScreen
            },
          ),

          ListTile(
            leading: const Icon(Icons.verified),
            title: const Text('Version 1.0.0'),
            onTap: () {}, // No action needed
          ),
        ],
      ),
    );
  }
}
