import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/card_contact.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('contacts.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

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

  Future<int> insertContact(CardContact contact) async {
    final db = await instance.database;
    return await db.insert('contacts', contact.toMap());
  }

  Future<List<CardContact>> getAllContacts() async {
    final db = await instance.database;
    final result = await db.query('contacts');
    return result.map((map) => CardContact.fromMap(map)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
