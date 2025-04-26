// capture_preview_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';

class CapturePreviewScreen extends StatelessWidget {
  final String imagePath;

  const CapturePreviewScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Capture'),
        centerTitle: true, // 🎯 Centered title for cleaner UI
      ),
      body: Column(
        children: [
          // 🖼️ Display captured image
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain, // 👌 Better fit for business cards
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 🧩 Action buttons: Retake or Use
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // 🔁 Retake
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retake'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.redAccent, // ❌ Retake = red color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/preview',
                        arguments: imagePath,
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Use Photo'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.green, // ✅ Use = green color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
