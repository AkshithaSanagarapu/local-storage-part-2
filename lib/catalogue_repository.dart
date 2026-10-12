
import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';
import 'folder.dart';
import 'card_record.dart';

class CatalogueRepository {
  final DatabaseHelper helper;

  CatalogueRepository(this.helper);

  Future<Database> get _db async {
    return helper.database;
  }

  // Create a new folder.
  Future<int> insertFolder(String name) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      throw ArgumentError('Folder name cannot be empty.');
    }

    final db = await _db;

    final folder = Folder(
      name: trimmedName,
      createdAt: DateTime.now().toIso8601String(),
    );

    return db.insert('folders', folder.toMap());
  }

  // Retrieve folders and their card counts.
  Future<List<Folder>> getFoldersWithCounts() async {
    final db = await _db;

    final rows = await db.rawQuery('''
      SELECT
        folders.id,
        folders.name,
        folders.created_at,
        COUNT(cards.id) AS card_count
      FROM folders
      LEFT JOIN cards
        ON folders.id = cards.folder_id
      GROUP BY
        folders.id,
        folders.name,
        folders.created_at
      ORDER BY folders.name COLLATE NOCASE ASC
    ''');

    return rows.map((row) => Folder.fromMap(row)).toList();
  }

  // Retrieve cards belonging to one folder.
  Future<List<CardRecord>> getCards(int folderId) async {
    final db = await _db;

    final rows = await db.query(
      'cards',
      where: 'folder_id = ?',
      whereArgs: [folderId],
      orderBy: 'title COLLATE NOCASE ASC',
    );

    return rows.map((row) => CardRecord.fromMap(row)).toList();
  }

  // Validate a card before writing.
  Future<void> _validateCard(CardRecord card) async {
    if (card.title.trim().isEmpty) {
      throw ArgumentError('Card title cannot be empty.');
    }

    const validSuits = {
      'Hearts',
      'Diamonds',
      'Clubs',
      'Spades',
    };

    if (!validSuits.contains(card.suit)) {
      throw ArgumentError('Please select a valid suit.');
    }

    final db = await _db;

    final folders = await db.query(
      'folders',
      columns: ['id'],
      where: 'id = ?',
      whereArgs: [card.folderId],
      limit: 1,
    );

    if (folders.isEmpty) {
      throw ArgumentError('Selected folder does not exist.');
    }
  }

  // Create a card.
  Future<int> insertCard(CardRecord card) async {
    await _validateCard(card);

    final db = await _db;

    final values = card.toMap();
    values.remove('id');
    values['title'] = card.title.trim();

    return db.insert('cards', values);
  }

  // Edit an existing card by ID.
  Future<int> updateCard(CardRecord card) async {
    if (card.id == null) {
      throw ArgumentError('Card ID is required for editing.');
    }

    await _validateCard(card);

    final db = await _db;

    final values = card.toMap();
    values.remove('id');
    values['title'] = card.title.trim();

    return db.update(
      'cards',
      values,
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  // Delete a card by ID.
  Future<int> deleteCard(int id) async {
    final db = await _db;

    return db.delete(
      'cards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a folder and its cards using CASCADE.
  Future<int> deleteFolder(int id) async {
    final db = await _db;

    return db.delete(
      'folders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
