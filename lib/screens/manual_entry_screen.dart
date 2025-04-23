import 'package:flutter/material.dart';
import '../models/card_contact.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({Key? key}) : super(key: key);

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _notesController = TextEditingController();

  void _saveContact() {
    if (_formKey.currentState!.validate()) {
      final newContact = CardContact(
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        company: _companyController.text,
        jobTitle: _jobTitleController.text,
        notes: _notesController.text,
      );

      // TODO: Connect to local DB (e.g. isar or sqflite)

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact saved successfully!')),
      );

      Navigator.pop(context); // Return to previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(labelText: 'Company'),
              ),
              TextFormField(
                controller: _jobTitleController,
                decoration: const InputDecoration(labelText: 'Job Title'),
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save Contact'),
                onPressed: _saveContact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
