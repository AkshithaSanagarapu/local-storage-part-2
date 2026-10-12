
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = 'MyDatabase.db';
  static const _databaseVersion = 2;

  static const table = 'my_table';
  static const columnId = '_id';
  static const columnName = 'name';
  static const columnAge = 'age';

  late Database _db;
  Database get database => _db;

  Future<void> init() async {
    final documentsDirectory =
        await getApplicationDocumentsDirectory();

    final path = join(
      documentsDirectory.path,
      _databaseName,
    );

    _db = await openDatabase(
      path,
      version: _databaseVersion,

      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      onCreate: (db, version) async {
        await _createOriginalTable(db);
        await _createCatalogueTables(db);
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createCatalogueTables(db);
        }
      },
    );
  }

  // Preserve the original Activity 08 table.
  Future<void> _createOriginalTable(Database db) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnAge INTEGER NOT NULL
      )
    ''');
  }

  // Create the new Activity 09 tables.
  Future<void> _createCatalogueTables(Database db) async {
    await db.execute('''
      CREATE TABLE folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        suit TEXT NOT NULL,
        notes TEXT NOT NULL DEFAULT '',
        image_ref TEXT,
        folder_id INTEGER NOT NULL,
        FOREIGN KEY (folder_id)
          REFERENCES folders(id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_cards_folder_id
      ON cards(folder_id)
    ''');
  }

  // Existing Activity 08 CRUD operations.

  Future<int> insert(Map<String, dynamic> row) async {
    return _db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    return _db.query(table);
  }

  Future<int> queryRowCount() async {
    final results = await _db.rawQuery(
      'SELECT COUNT(*) FROM $table',
    );

    return Sqflite.firstIntValue(results) ?? 0;
  }

  Future<int> update(Map<String, dynamic> row) async {
    final int id = row[columnId] as int;

    return _db.update(
      table,
      row,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    return _db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  // Read-only migration verification methods.

  Future<int> getSchemaVersion() async {
    final rows = await _db.rawQuery(
      'PRAGMA user_version',
    );

    return rows.first['user_version'] as int;
  }

  Future<int> getForeignKeysEnabled() async {
    final rows = await _db.rawQuery(
      'PRAGMA foreign_keys',
    );

    return rows.first['foreign_keys'] as int;
  }
}
