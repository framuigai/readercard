// privacy_policy_screen.dart
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Privacy Policy', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text(
                'CardReader respects your privacy.\n\n'
                    '• We store your scanned business cards locally on your device.\n'
                    '• We do not collect or share your data.\n'
                    '• Cloud backup (optional) will be encrypted and private.\n\n'
                    'By using this app, you agree to this privacy policy.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
