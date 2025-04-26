// camera_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../main.dart'; // Access global cameras list

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(cameras.first, ResolutionPreset.medium);
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
      });
    }).catchError((e) {
      debugPrint('Camera error: $e');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _captureImage() async {
    if (!_controller.value.isInitialized) return;
    try {
      final image = await _controller.takePicture();
      Navigator.pushNamed(context, '/capture-preview', arguments: image.path); // ✅ Go to capture preview
    } catch (e) {
      debugPrint('Capture error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = screenWidth * 0.7; // 🎯 Width of focus box
    final boxHeight = boxWidth * 0.6; // 🎯 Height of focus box

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Business Card')),
      body: _isInitialized
          ? Stack(
        children: [
          CameraPreview(_controller), // 📸 Live camera
          _buildFocusOverlay(boxWidth, boxHeight), // 🎯 Overlay blur with clear center
          Center(
            child: Container(
              width: boxWidth,
              height: boxHeight,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Align the card inside the box",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _captureImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capture'),
              ),
            ),
          ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildFocusOverlay(double boxWidth, double boxHeight) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final centerX = screenWidth / 2;
        final centerY = screenHeight / 2;

        final rect = Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: boxWidth,
          height: boxHeight,
        );

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // ✅ Blur around
          child: CustomPaint(
            size: Size(screenWidth, screenHeight),
            painter: FocusPainter(rect: rect), // 🎯 Clear center
          ),
        );
      },
    );
  }
}

// 🎨 Painter for focus clear hole
class FocusPainter extends CustomPainter {
  final Rect rect;

  FocusPainter({required this.rect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Darken the whole screen
    canvas.drawRect(Offset.zero & size, paint);

    // Clear the focus area
    paint.blendMode = BlendMode.clear;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
