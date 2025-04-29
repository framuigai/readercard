// main.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/capture_preview_screen.dart'; // ✅ Correctly import
import 'screens/card_preview_screen.dart';    // ✅ Correctly import
import 'screens/cardholder_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/premium_screen.dart';
import 'screens/manual_entry_screen.dart';
import 'theme/app_theme.dart';
import 'screens/about_screen.dart';          // 🆕 About
import 'screens/privacy_policy.dart';        // 🆕 Privacy Policy

// Declare a global camera list
late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const CardReaderApp());
}

class CardReaderApp extends StatelessWidget {
  const CardReaderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CardReader',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/camera': (context) => const CameraScreen(),
        '/manual-entry': (context) => const ManualEntryScreen(),
        '/cardholder': (context) => const CardholderScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/about': (context) => const AboutScreen(),             // 🆕 Added
        '/privacy-policy': (context) => const PrivacyPolicyScreen(), // 🆕 Added
      },
      // Handle screens needing arguments separately
      onGenerateRoute: (settings) {
        if (settings.name == '/capture-preview') {
          final path = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => CapturePreviewScreen(imagePath: path),
          );
        }
        if (settings.name == '/preview') {
          final path = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => CardPreviewScreen(imagePath: path),
          );
        }

        // ✅ 🆕 Handle About and Privacy Policy screens
        if (settings.name == '/about') {
          return MaterialPageRoute(builder: (context) => const AboutScreen());
        }
        if (settings.name == '/privacy-policy') {
          return MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen());
        }

        return null;
      },
    );
  }
}
