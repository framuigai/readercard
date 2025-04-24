import 'dart:io';
import 'package:flutter/material.dart';
import '../models/card_contact.dart';
import '../services/db_helper.dart';
import 'card_details_screen.dart'; // 🆕 Ensure this import exists

class CardholderScreen extends StatefulWidget {
  const CardholderScreen({Key? key}) : super(key: key);

  @override
  State<CardholderScreen> createState() => _CardholderScreenState();
}

class _CardholderScreenState extends State<CardholderScreen> {
  late Future<List<CardContact>> _contactsFuture;
  List<CardContact> _allContacts = []; // Holds all fetched contacts
  List<CardContact> _filteredContacts = []; // Filtered list for display
  final TextEditingController _searchController = TextEditingController(); // 🔍 Search input controller

  @override
  void initState() {
    super.initState();
    _loadContacts(); // 🔄 Load contacts on start
    _searchController.addListener(_onSearchChanged); // 📝 Listen for search input
  }

  @override
  void dispose() {
    _searchController.dispose(); // 🧹 Dispose controller
    super.dispose();
  }

  void _loadContacts() {
    _contactsFuture = DBHelper.instance.getAllContacts();
    _contactsFuture.then((contacts) {
      setState(() {
        _allContacts = contacts;
        _filteredContacts = contacts; // By default, show all
      });
    });
  }

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

  // 🚀 Navigate to details page and refresh after return
  Future<void> _navigateToDetails(CardContact contact) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardDetailsScreen(contact: contact),
      ),
    );
    if (updated == true) {
      _loadContacts(); // Refresh if updated or deleted
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Business Cards')),
      body: Column(
        children: [
          // 🔎 Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, email, or company',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // 🔄 Contacts List
          Expanded(
            child: _filteredContacts.isEmpty
                ? const Center(child: Text('No matching contacts found.'))
                : ListView.builder(
              itemCount: _filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = _filteredContacts[index];

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
                    onTap: () => _navigateToDetails(contact),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
