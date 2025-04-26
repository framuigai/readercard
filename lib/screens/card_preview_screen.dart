import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p; // ✅ Avoid conflicts with context
import 'package:path_provider/path_provider.dart';
import '../models/card_contact.dart';
import '../services/db_helper.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CardPreviewScreen extends StatefulWidget {
  final String imagePath; // 🖼️ Path to the captured image

  const CardPreviewScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<CardPreviewScreen> createState() => _CardPreviewScreenState();
}

class _CardPreviewScreenState extends State<CardPreviewScreen> {
  // 🧠 Text editing controllers for the form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isProcessing = true; // 🔄 Flag to show loading spinner during OCR

  @override
  void initState() {
    super.initState();
    _performOCR(File(widget.imagePath)); // 📷 Start OCR on the captured image
  }

  // 🔍 OCR logic: scan the image and populate fields
  Future<void> _performOCR(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    final text = recognizedText.text;

    // 📝 Extract important lines (basic keyword matching)
    _nameController.text = _extractLineContaining(text, ['name']);
    _phoneController.text = _extractLineContaining(text, ['+254', '07', 'phone']);
    _emailController.text = _extractLineContaining(text, ['@']);
    _companyController.text = _extractLineContaining(text, ['ltd', 'company', 'inc']);
    _jobTitleController.text = '';
    _notesController.text = text; // 📋 Save full OCR text to notes

    setState(() {
      _isProcessing = false; // ⏳ Stop loading after OCR complete
    });
  }

  // 🔍 Helper: find the first matching line for given keywords
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

  // 💾 Save button logic: copy image, save contact to DB
  Future<void> _saveContact() async {
    final dir = await getApplicationDocumentsDirectory();
    final cardsDir = Directory(p.join(dir.path, 'cards'));

    if (!await cardsDir.exists()) {
      await cardsDir.create(recursive: true);
    }

    final newImagePath = p.join(cardsDir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
    await File(widget.imagePath).copy(newImagePath);

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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Contact saved successfully!')),
    );

    Navigator.popUntil(context, ModalRoute.withName('/home'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview & Edit')),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator()) // ⏳ Show loader during OCR
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🖼️ Display captured image
          Image.file(File(widget.imagePath), height: 200, fit: BoxFit.cover),
          const SizedBox(height: 20),

          const Text('Edit Details:', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 12),

          // 📋 Editable fields with spacing
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 12),
          TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone')),
          const SizedBox(height: 12),
          TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 12),
          TextField(controller: _companyController, decoration: const InputDecoration(labelText: 'Company')),
          const SizedBox(height: 12),
          TextField(controller: _jobTitleController, decoration: const InputDecoration(labelText: 'Job Title')),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Notes'),
            maxLines: 3,
          ),
          const SizedBox(height: 24),

          // 💾 Save Button
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save Contact'),
            onPressed: _saveContact,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
