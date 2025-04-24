import 'dart:io';
import 'package:flutter/material.dart';
import '../models/card_contact.dart';
import '../services/db_helper.dart';

class CardDetailsScreen extends StatefulWidget {
  final CardContact contact;
  const CardDetailsScreen({Key? key, required this.contact}) : super(key: key);

  @override
  State<CardDetailsScreen> createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends State<CardDetailsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _companyController;
  late TextEditingController _jobTitleController;
  late TextEditingController _notesController;

  bool _isEditing = false; // ✍️ Start in read-only mode

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact.name);
    _phoneController = TextEditingController(text: widget.contact.phone);
    _emailController = TextEditingController(text: widget.contact.email);
    _companyController = TextEditingController(text: widget.contact.company);
    _jobTitleController = TextEditingController(text: widget.contact.jobTitle);
    _notesController = TextEditingController(text: widget.contact.notes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _jobTitleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ✅ Save edited contact to DB
  Future<void> _saveChanges() async {
    final updated = CardContact(
      id: widget.contact.id,
      imagePath: widget.contact.imagePath,
      name: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      company: _companyController.text,
      jobTitle: _jobTitleController.text,
      notes: _notesController.text,
    );
    await DBHelper.instance.updateContact(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact updated.')),
    );
    Navigator.pop(context, true); // ✅ Signal refresh
  }

  // 🗑️ Confirm delete then remove contact
  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Contact'),
        content: const Text('Are you sure you want to delete this contact?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes')),
        ],
      ),
    );

    if (confirmed == true) {
      await DBHelper.instance.deleteContact(widget.contact.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact deleted.')),
      );
      Navigator.pop(context, true); // ✅ Signal refresh
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      maxLines: maxLines,
      enabled: _isEditing,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Details'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveChanges();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🖼️ Display image
          File(widget.contact.imagePath).existsSync()
              ? Image.file(File(widget.contact.imagePath), height: 200, fit: BoxFit.cover)
              : const Icon(Icons.broken_image, size: 100),

          const SizedBox(height: 16),
          _buildTextField('Name', _nameController),
          _buildTextField('Phone', _phoneController),
          _buildTextField('Email', _emailController),
          _buildTextField('Company', _companyController),
          _buildTextField('Job Title', _jobTitleController),
          _buildTextField('Notes', _notesController, maxLines: 3),
        ],
      ),
    );
  }
}
