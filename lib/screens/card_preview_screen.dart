import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p; // ✅ Use alias to avoid conflict with BuildContext
import 'package:path_provider/path_provider.dart';
import '../models/card_contact.dart';
import '../services/db_helper.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CardPreviewScreen extends StatefulWidget {
  const CardPreviewScreen({Key? key}) : super(key: key);

  @override
  State<CardPreviewScreen> createState() => _CardPreviewScreenState();
}

class _CardPreviewScreenState extends State<CardPreviewScreen> {
  // 🧠 Text controllers for form fields
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

    // 👇 Delay access to ModalRoute to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context);
      if (route?.settings.arguments is String) {
        setState(() {
          imagePath = route!.settings.arguments as String;
        });
        _performOCR(File(imagePath));
      } else {
        debugPrint('❗ No valid image path found in route arguments.');
      }
    });
  }

  /// 🔍 Perform OCR and fill form with basic guesses
  Future<void> _performOCR(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    final text = recognizedText.text;

    // ⛏️ Try extracting key fields using keyword matching
    _nameController.text = _extractLineContaining(text, ['name']);
    _phoneController.text = _extractLineContaining(text, ['+254', '07', 'phone']);
    _emailController.text = _extractLineContaining(text, ['@']);
    _companyController.text = _extractLineContaining(text, ['ltd', 'company', 'inc']);
    _jobTitleController.text = '';
    _notesController.text = text;

    setState(() {
      _isProcessing = false;
    });
  }

  /// 🔍 Helper to extract matching lines from text
  String _extractLineContaining(String text, List<String> keywords) {
    final lines = text.split('\n');
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
          // 🖼️ Image display
          Image.file(File(imagePath), height: 200, fit: BoxFit.cover),
          const SizedBox(height: 20),

          const Text('Edit Details:', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),

          // 🧾 Editable fields
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

          // 💾 Save contact
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save Contact'),
            onPressed: () async {
              // 📁 Save image file to local storage
              final dir = await getApplicationDocumentsDirectory();
              final cardsDir = Directory(p.join(dir.path, 'cards'));
              if (!await cardsDir.exists()) {
                await cardsDir.create(recursive: true);
              }

              final newImagePath = p.join(cardsDir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
              await File(imagePath).copy(newImagePath);

              // 🧠 Save contact data
              final contact = CardContact(
                imagePath: newImagePath,
                name: _nameController.text,
                phone: _phoneController.text,
                email: _emailController.text,
                company: _companyController.text,
                jobTitle: _jobTitleController.text,
                notes: _notesController.text,
              );

              await DBHelper.instance.insertContact(contact);

              // ✅ Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contact saved locally!')),
              );

              // 🔁 Return to home
              Navigator.popUntil(context, ModalRoute.withName('/home'));
            },
          ),
        ],
      ),
    );
  }
}
