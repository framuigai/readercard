// cardholder_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/card_contact.dart';
import '../services/db_helper.dart';
import 'card_details_screen.dart'; // 🆕 Make sure this import exists

class CardholderScreen extends StatefulWidget {
  const CardholderScreen({Key? key}) : super(key: key);

  @override
  State<CardholderScreen> createState() => _CardholderScreenState();
}

class _CardholderScreenState extends State<CardholderScreen> {
  late Future<List<CardContact>> _contactsFuture;
  List<CardContact> _allContacts = []; // Holds all contacts from DB
  List<CardContact> _filteredContacts = []; // Filtered contacts based on search
  final TextEditingController _searchController = TextEditingController(); // 🔍 Controller for search bar

  @override
  void initState() {
    super.initState();
    _loadContacts(); // Initial loading
    _searchController.addListener(_onSearchChanged); // Listen for search typing
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 🗂️ Fetch contacts from local DB
  void _loadContacts() {
    _contactsFuture = DBHelper.instance.getAllContacts();
    _contactsFuture.then((contacts) {
      setState(() {
        _allContacts = contacts;
        _filteredContacts = contacts; // Initially show all
      });
    });
  }

  // 🔍 Handle search logic
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = _allContacts.where((contact) {
        return contact.name.toLowerCase().contains(query) ||
            contact.email.toLowerCase().contains(query) ||
            contact.company.toLowerCase().contains(query);
      }).toList();
    });
  }

  // 🚀 Navigate to CardDetailsScreen when a card is tapped
  Future<void> _navigateToDetails(CardContact contact) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardDetailsScreen(contact: contact),
      ),
    );
    if (updated == true) {
      _loadContacts(); // Refresh if contact edited or deleted
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Business Cards'),
      ),
      body: Column(
        children: [
          // 🔎 Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search by name, email, or company',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          // 🧾 Card List
          Expanded(
            child: FutureBuilder<List<CardContact>>(
              future: _contactsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('⚠️ Error loading contacts.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No cards saved yet.'));
                }

                return _buildContactList();
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🖼️ Build the cards nicely
  Widget _buildContactList() {
    return ListView.builder(
      itemCount: _filteredContacts.length,
      itemBuilder: (context, index) {
        final contact = _filteredContacts[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: 3,
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: File(contact.imagePath).existsSync()
                  ? Image.file(
                File(contact.imagePath),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )
                  : const Icon(Icons.broken_image, size: 60),
            ),
            title: Text(
              contact.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  contact.jobTitle,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  contact.email,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            isThreeLine: true,
            onTap: () => _navigateToDetails(contact),
          ),
        );
      },
    );
  }
}
