import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../models/laporan.dart';

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
      dbPath = 'anpundung_web.db';
    } else {
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      dbPath = join(await getDatabasesPath(), 'anpundung_bandung.db');
    }

    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE laporan_pungli (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nomor TEXT NOT NULL,
            kategori TEXT NOT NULL,
            lokasi TEXT NOT NULL,
            deskripsi TEXT NOT NULL,
            waktu TEXT NOT NULL,
            status TEXT NOT NULL,
            nominal INTEGER NOT NULL,
            is_anonim INTEGER NOT NULL
          )
        ''');

        // Data awal (seed data) agar saat aplikasi pertama kali dipasang sudah memiliki riwayat
        final dataAwal = [
          Laporan(
            nomor: 'ANP-2408',
            kategori: 'Pelayanan publik',
            lokasi: 'Kecamatan Coblong',
            deskripsi: 'Diminta biaya tambahan untuk pengurusan surat pengantar.',
            waktu: DateTime(2026, 10, 18, 9, 30),
            status: 'Sedang ditinjau',
            nominal: 50000,
            isAnonim: true,
          ),
          Laporan(
            nomor: 'ANP-2403',
            kategori: 'Perizinan',
            lokasi: 'Kecamatan Lengkong',
            deskripsi: 'Ada permintaan uang di luar biaya resmi retribusi.',
            waktu: DateTime(2026, 10, 16, 13, 15),
            status: 'Terverifikasi',
            nominal: 100000,
            isAnonim: true,
          ),
        ];

        for (final item in dataAwal) {
          await db.insert('laporan_pungli', item.toMap());
        }
      },
    );
  }

  // CREATE
  Future<int> tambahLaporan(Laporan laporan) async {
    final db = await database;
    return db.insert('laporan_pungli', laporan.toMap());
  }

  // READ
  Future<List<Laporan>> ambilSemuaLaporan() async {
    final db = await database;
    final rows = await db.query('laporan_pungli', orderBy: 'id DESC');
    return rows.map(Laporan.fromMap).toList();
  }

  Future<Laporan?> ambilLaporanById(int id) async {
    final db = await database;
    final rows = await db.query(
      'laporan_pungli',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Laporan.fromMap(rows.first);
  }

  // UPDATE
  Future<int> ubahLaporan(Laporan laporan) async {
    final db = await database;
    return db.update(
      'laporan_pungli',
      laporan.toMap(),
      where: 'id = ?',
      whereArgs: [laporan.id],
    );
  }

  // DELETE
  Future<int> hapusLaporan(int id) async {
    final db = await database;
    return db.delete(
      'laporan_pungli',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

