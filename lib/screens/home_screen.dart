// home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🏡 App Bar
      appBar: AppBar(
        title: const Text('CardReader'),
        centerTitle: true,
      ),

      // 📋 Drawer Menu
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // 🎨 Drawer Header
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.credit_card, color: Colors.white, size: 48),
                  SizedBox(height: 10),
                  Text(
                    'CardReader',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // 📚 Menu Items
            _buildDrawerItem(
              icon: Icons.home,
              text: 'Home',
              onTap: () => Navigator.pushReplacementNamed(context, '/home'),
            ),
            _buildDrawerItem(
              icon: Icons.contact_page,
              text: 'Cardholder',
              onTap: () => Navigator.pushNamed(context, '/cardholder'),
            ),
            _buildDrawerItem(
              icon: Icons.settings,
              text: 'Settings',
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
            _buildDrawerItem(
              icon: Icons.star,
              text: 'Premium',
              onTap: () => Navigator.pushNamed(context, '/premium'),
            ),
            _buildDrawerItem(
              icon: Icons.info,
              text: 'About',
              onTap: () => Navigator.pushNamed(context, '/about'),
            ),
          ],
        ),
      ),

      // 📸 Main Action Buttons
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50), // Make button wider
                ),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Scan Business Card'),
                onPressed: () => Navigator.pushNamed(context, '/camera'),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                icon: const Icon(Icons.edit),
                label: const Text('Enter Card Manually'),
                onPressed: () => Navigator.pushNamed(context, '/manual-entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔧 Helper method for drawer items
  Widget _buildDrawerItem({required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: onTap,
    );
  }
}
