import 'dart:io';
import 'package:flutter/material.dart';
import '../models/card_contact.dart';
import '../services/db_helper.dart';

class CardholderScreen extends StatefulWidget {
  const CardholderScreen({Key? key}) : super(key: key);

  @override
  State<CardholderScreen> createState() => _CardholderScreenState();
}

class _CardholderScreenState extends State<CardholderScreen> {
  late Future<List<CardContact>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    // 🗃️ Load saved business cards from local DB
    _contactsFuture = DBHelper.instance.getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Business Cards')),
      body: FutureBuilder<List<CardContact>>(
        future: _contactsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('⚠️ Error loading contacts.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No cards saved yet.'));
          }

          final contacts = snapshot.data!;
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: File(contact.imagePath).existsSync()
                      ? Image.file(
                    File(contact.imagePath),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.broken_image, size: 50),

                  title: Text(contact.name),
                  subtitle: Text('${contact.jobTitle}\n${contact.email}'),
                  isThreeLine: true,
                  onTap: () {
                    // 🔜 Optional: open details/edit screen
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
