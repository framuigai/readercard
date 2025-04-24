import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/card_contact.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  // Singleton database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('contacts.db');
    return _database!;
  }

  // Initialize the SQLite database
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Create contacts table
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        imagePath TEXT,
        name TEXT,
        phone TEXT,
        email TEXT,
        company TEXT,
        jobTitle TEXT,
        notes TEXT
      )
    ''');
  }

  // Insert a new card into DB
  Future<int> insertContact(CardContact contact) async {
    final db = await instance.database;
    return await db.insert('contacts', contact.toMap());
  }

  // Fetch all saved cards
  Future<List<CardContact>> getAllContacts() async {
    final db = await instance.database;
    final result = await db.query('contacts');
    return result.map((map) => CardContact.fromMap(map)).toList();
  }

  // ✅ Update a contact by ID
  Future<int> updateContact(CardContact contact) async {
    final db = await instance.database;
    return await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  // 🗑️ Delete a contact by ID
  Future<int> deleteContact(int id) async {
    final db = await instance.database;
    return await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Close DB connection
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
