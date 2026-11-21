import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../models/pesanan.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String dbPath;
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      dbPath = 'kantin_kampus_web.db';
    } else {
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      dbPath = join(await getDatabasesPath(), 'kantin_kampus.db');
    }

    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pesanan (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ringkasan_item TEXT NOT NULL,
            total_item INTEGER NOT NULL,
            total_harga INTEGER NOT NULL,
            tanggal TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> tambahPesanan(Pesanan pesanan) async {
    final db = await database;
    return db.insert('pesanan', pesanan.toMap());
  }

  Future<List<Pesanan>> ambilSemuaPesanan() async {
    final db = await database;
    final rows = await db.query('pesanan', orderBy: 'id DESC');
    return rows.map(Pesanan.fromMap).toList();
  }

  Future<int> ubahPesanan(Pesanan pesanan) async {
    final db = await database;
    return db.update(
      'pesanan',
      pesanan.toMap(),
      where: 'id = ?',
      whereArgs: [pesanan.id],
    );
  }

  Future<int> ubahJumlahItem(int id, int jumlahBaru) async {
    final db = await database;
    return db.update(
      'pesanan',
      {'total_item': jumlahBaru},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> hapusPesanan(int id) async {
    final db = await database;
    return db.delete('pesanan', where: 'id = ?', whereArgs: [id]);
  }
}
