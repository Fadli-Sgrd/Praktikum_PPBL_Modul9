// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pantauan_laporan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PantauanLaporanAdapter extends TypeAdapter<PantauanLaporan> {
  @override
  final int typeId = 0;

  @override
  PantauanLaporan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PantauanLaporan(
      nomorLaporan: fields[0] as String,
      kategori: fields[1] as String,
      lokasi: fields[2] as String,
      deskripsi: fields[3] as String,
      nominal: fields[4] as int,
      status: fields[5] as String,
      waktu: fields[6] as String,
      catatanPribadi: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PantauanLaporan obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.nomorLaporan)
      ..writeByte(1)
      ..write(obj.kategori)
      ..writeByte(2)
      ..write(obj.lokasi)
      ..writeByte(3)
      ..write(obj.deskripsi)
      ..writeByte(4)
      ..write(obj.nominal)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.waktu)
      ..writeByte(7)
      ..write(obj.catatanPribadi);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PantauanLaporanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
