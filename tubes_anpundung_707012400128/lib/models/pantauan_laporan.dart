import 'package:hive/hive.dart';

part 'pantauan_laporan.g.dart';

@HiveType(typeId: 0)
class PantauanLaporan extends HiveObject {
  @HiveField(0)
  late String nomorLaporan;

  @HiveField(1)
  late String kategori;

  @HiveField(2)
  late String lokasi;

  @HiveField(3)
  late String deskripsi;

  @HiveField(4)
  late int nominal;

  @HiveField(5)
  late String status;

  @HiveField(6)
  late String waktu;

  @HiveField(7)
  String catatanPribadi = '';

  PantauanLaporan({
    required this.nomorLaporan,
    required this.kategori,
    required this.lokasi,
    required this.deskripsi,
    required this.nominal,
    required this.status,
    required this.waktu,
    this.catatanPribadi = '',
  });
}
