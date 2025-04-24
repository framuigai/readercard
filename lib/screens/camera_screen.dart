import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../main.dart'; // To access the global `cameras` list

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

    // Initialize the camera with the first (usually back) camera
    _controller = CameraController(cameras.first, ResolutionPreset.medium);
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Free camera resources
    super.dispose();
  }

  void _captureImage() async {
    if (!_controller.value.isInitialized) return;

    try {
      final image = await _controller.takePicture();
      Navigator.pushNamed(context, '/preview', arguments: image.path);
    } catch (e) {
      // Optional: show error to user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Business Card')),
      body: _isInitialized
          ? Stack(
        children: [
          CameraPreview(_controller), // 🔍 Camera feed
          Center(
            child: Container(
              width: 250,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: _captureImage,
                child: const Icon(Icons.camera_alt),
              ),
            ),
          ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
