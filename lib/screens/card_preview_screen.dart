import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p; // 🧠 Alias path to avoid conflict
import 'package:path_provider/path_provider.dart';
import '../models/card_contact.dart';
import '../services/db_helper.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CardPreviewScreen extends StatefulWidget {
  final String imagePath; // 📸 Path to captured image

  const CardPreviewScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<CardPreviewScreen> createState() => _CardPreviewScreenState();
}

class _CardPreviewScreenState extends State<CardPreviewScreen> {
  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isProcessing = true; // 🔄 While OCR is ongoing
  bool _isSaving = false; // 🔄 While saving contact

  @override
  void initState() {
    super.initState();
    _performOCR(File(widget.imagePath));
  }

  /// 🧠 OCR Scanning Logic
  Future<void> _performOCR(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      final text = recognizedText.text.trim();

      if (text.isEmpty) {
        // 🚨 No text detected
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⚠️ No text detected. Please retake the photo.')),
          );
        }
        Navigator.pop(context); // Go back to retake
        return;
      }

      // Populate fields from OCR
      _nameController.text = _extractLineContaining(text, ['name']);
      _phoneController.text = _extractLineContaining(text, ['+254', '07', 'phone']);
      _emailController.text = _extractLineContaining(text, ['@']);
      _companyController.text = _extractLineContaining(text, ['ltd', 'company', 'inc']);
      _jobTitleController.text = '';
      _notesController.text = text;
    } catch (e) {
      // 🚨 OCR failed (invalid image)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Error processing image. Please try again.')),
        );
      }
      Navigator.pop(context);
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  /// 🧠 Simple helper to extract a relevant line from OCR output
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

  /// 💾 Save the scanned contact
  Future<void> _saveContact() async {
    // 🔍 Validate fields before saving
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Name is required.')),
      );
      return;
    }

    if (email.isNotEmpty && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Enter a valid email address.')),
      );
      return;
    }

    if (phone.isNotEmpty && !RegExp(r'^(\+?\d{7,15})$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Enter a valid phone number.')),
      );
      return;
    }

    setState(() {
      _isSaving = true; // Start saving loader
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final cardsDir = Directory(p.join(dir.path, 'cards'));

      if (!await cardsDir.exists()) {
        await cardsDir.create(recursive: true);
      }

      final newImagePath = p.join(cardsDir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
      await File(widget.imagePath).copy(newImagePath);

      final contact = CardContact(
        imagePath: newImagePath,
        name: name,
        phone: phone,
        email: email,
        company: _companyController.text.trim(),
        jobTitle: _jobTitleController.text.trim(),
        notes: _notesController.text.trim(),
      );

      await DBHelper.instance.insertContact(contact);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Contact saved successfully!')),
        );
        Navigator.popUntil(context, ModalRoute.withName('/home'));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Failed to save contact.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false; // Stop saving loader
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview & Edit')),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator()) // OCR Loading spinner
          : _isSaving
          ? const Center(child: CircularProgressIndicator()) // Saving spinner
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Image.file(File(widget.imagePath), height: 200, fit: BoxFit.cover),
          const SizedBox(height: 20),
          const Text('Edit Details:', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 16),

          // TextFields with better spacing
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 16),
          TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone')),
          const SizedBox(height: 16),
          TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 16),
          TextField(controller: _companyController, decoration: const InputDecoration(labelText: 'Company')),
          const SizedBox(height: 16),
          TextField(controller: _jobTitleController, decoration: const InputDecoration(labelText: 'Job Title')),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Notes'),
            maxLines: 3,
          ),
          const SizedBox(height: 30),

          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save Contact'),
            onPressed: _saveContact,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
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
