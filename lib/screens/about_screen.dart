// about_screen.dart
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About CardReader'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('CardReader App', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text(
              'CardReader helps you scan business cards quickly and save them to your device.\n\n'
                  'Easily manage your professional contacts and keep your important information organized.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text('Version: 1.0.0', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Developer: Your Name Here', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
