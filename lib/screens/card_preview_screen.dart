import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CardPreviewScreen extends StatefulWidget {
  const CardPreviewScreen({Key? key}) : super(key: key);

  @override
  State<CardPreviewScreen> createState() => _CardPreviewScreenState();
}

class _CardPreviewScreenState extends State<CardPreviewScreen> {
  // TextEditingControllers to hold extracted and editable text
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isProcessing = true;
  String imagePath = '';

  @override
  void initState() {
    super.initState();
    // Delay OCR to after build to access arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args is String) {
        imagePath = args;
        _performOCR(File(imagePath));
      }
    });
  }

  // 🔍 Perform OCR and populate text fields
  Future<void> _performOCR(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    textRecognizer.close();

    // Combine all extracted text
    String extracted = recognizedText.text;

    // Try basic matching — optional: enhance with RegEx later
    _nameController.text = _extractLineContaining(extracted, ['name']);
    _phoneController.text = _extractLineContaining(extracted, ['+254', '07', 'phone']);
    _emailController.text = _extractLineContaining(extracted, ['@']);
    _companyController.text = _extractLineContaining(extracted, ['ltd', 'company', 'inc']);
    _jobTitleController.text = ''; // Could use a dropdown or prediction later
    _notesController.text = extracted;

    setState(() {
      _isProcessing = false;
    });
  }

  // Helper to find a line with keywords
  String _extractLineContaining(String fullText, List<String> keywords) {
    final lines = fullText.split('\n');
    for (final keyword in keywords) {
      final match = lines.firstWhere(
            (line) => line.toLowerCase().contains(keyword.toLowerCase()),
        orElse: () => '',
      );
      if (match.isNotEmpty) return match.trim();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview & Edit')),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🖼️ Display the scanned image
          Image.file(File(imagePath), height: 200, fit: BoxFit.cover),
          const SizedBox(height: 20),

          const Text('Edit Details:', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),

          // ✏️ Editable fields pre-filled with OCR text
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone')),
          TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: _companyController, decoration: const InputDecoration(labelText: 'Company')),
          TextField(controller: _jobTitleController, decoration: const InputDecoration(labelText: 'Job Title')),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Notes'),
            maxLines: 3,
          ),

          const SizedBox(height: 20),

          // ✅ Save Button
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save Contact'),
            onPressed: () {
              // TODO: Save the contact using a DB or local storage
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contact saved locally!')),
              );
              Navigator.popUntil(context, ModalRoute.withName('/home'));
            },
          ),
        ],
      ),
    );
  }
}
