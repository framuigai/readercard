import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CardReader'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'CardReader',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pushReplacementNamed(context, '/home'),
            ),
            ListTile(
              leading: const Icon(Icons.contact_page),
              title: const Text('Cardholder'),
              onTap: () => Navigator.pushNamed(context, '/cardholder'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Premium'),
              onTap: () => Navigator.pushNamed(context, '/premium'),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () => Navigator.pushNamed(context, '/about'),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Business Card'),
              onPressed: () => Navigator.pushNamed(context, '/camera'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Enter Manually'),
              onPressed: () => Navigator.pushNamed(context, '/manual-entry'),
            ),
          ],
        ),
      ),
    );
  }
}