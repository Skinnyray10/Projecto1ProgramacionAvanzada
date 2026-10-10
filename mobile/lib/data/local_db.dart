import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/part.dart';

class PendingRegistration {
  const PendingRegistration({
    required this.id,
    required this.email,
    required this.fullName,
    this.lastError,
  });

  final int id;
  final String email;
  final String fullName;
  final String? lastError;
}

/// Caché offline: catálogo de piezas, registros pendientes de enviar y metadatos.
class LocalDb {
  Database? _db;

  Future<Database> get _database async =>
      _db ??= await openDatabase(
        p.join(await getDatabasesPath(), 'hmdp.db'),
        version: 1,
        onCreate: (db, _) async {
          await db.execute('''
            CREATE TABLE parts (
              id TEXT PRIMARY KEY,
              sku TEXT NOT NULL,
              name TEXT NOT NULL,
              brand TEXT,
              category TEXT,
              stock INTEGER NOT NULL,
              unit_price REAL NOT NULL,
              description TEXT,
              is_active INTEGER NOT NULL,
              updated_at TEXT
            )''');
          await db.execute('''
            CREATE TABLE pending_registrations (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              email TEXT NOT NULL UNIQUE,
              full_name TEXT NOT NULL,
              created_at TEXT NOT NULL,
              last_error TEXT
            )''');
          await db.execute(
              'CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT)');
        },
      );

  /// El servidor es la fuente de verdad: cada sincronización reemplaza el catálogo.
  Future<void> replaceParts(List<Part> parts) async {
    final db = await _database;
    await db.transaction((txn) async {
      await txn.delete('parts');
      final batch = txn.batch();
      for (final part in parts) {
        batch.insert('parts', part.toDb());
      }
      await batch.commit(noResult: true);
    });
  }

  Future<List<Part>> searchParts({String query = '', String? category}) async {
    final db = await _database;
    final where = <String>['is_active = 1'];
    final args = <Object?>[];
    final q = query.trim();
    if (q.isNotEmpty) {
      where.add(
          '(name LIKE ? OR sku LIKE ? OR brand LIKE ? OR category LIKE ?)');
      args.addAll(List.filled(4, '%$q%'));
    }
    if (category != null) {
      where.add('category = ?');
      args.add(category);
    }
    final rows = await db.query('parts',
        where: where.join(' AND '),
        whereArgs: args,
        orderBy: 'name COLLATE NOCASE');
    return rows.map(Part.fromDb).toList();
  }

  Future<List<String>> categories() async {
    final db = await _database;
    final rows = await db.rawQuery(
        'SELECT DISTINCT category FROM parts WHERE is_active = 1 AND category IS NOT NULL ORDER BY category COLLATE NOCASE');
    return rows.map((r) => r['category'] as String).toList();
  }

  Future<int> partCount() async {
    final db = await _database;
    return Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM parts')) ??
        0;
  }

  Future<String?> getMeta(String key) async {
    final db = await _database;
    final rows = await db.query('meta',
        columns: ['value'], where: 'key = ?', whereArgs: [key]);
    return rows.isEmpty ? null : rows.first['value'] as String?;
  }

  Future<void> setMeta(String key, String value) async {
    final db = await _database;
    await db.insert('meta', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> addPendingRegistration(String email, String fullName) async {
    final db = await _database;
    return db.insert(
      'pending_registrations',
      {
        'email': email,
        'full_name': fullName,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PendingRegistration>> pendingRegistrations() async {
    final db = await _database;
    final rows = await db.query('pending_registrations',
        where: 'last_error IS NULL', orderBy: 'id');
    return rows
        .map((r) => PendingRegistration(
              id: r['id'] as int,
              email: r['email'] as String,
              fullName: r['full_name'] as String,
            ))
        .toList();
  }

  Future<void> markRegistrationFailed(int id, String error) async {
    final db = await _database;
    await db.update('pending_registrations', {'last_error': error},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deletePendingRegistration(int id) async {
    final db = await _database;
    await db.delete('pending_registrations', where: 'id = ?', whereArgs: [id]);
  }
}
