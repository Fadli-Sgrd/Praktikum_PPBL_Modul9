class Laporan {
  const Laporan({
    this.id,
    required this.nomor,
    required this.kategori,
    required this.lokasi,
    required this.deskripsi,
    required this.waktu,
    this.status = 'Menunggu verifikasi',
    this.nominal = 0,
    this.isAnonim = true,
  });

  final int? id;
  final String nomor;
  final String kategori;
  final String lokasi;
  final String deskripsi;
  final DateTime waktu;
  final String status;
  final int nominal;
  final bool isAnonim;

  Laporan copyWith({
    int? id,
    String? nomor,
    String? kategori,
    String? lokasi,
    String? deskripsi,
    DateTime? waktu,
    String? status,
    int? nominal,
    bool? isAnonim,
  }) {
    return Laporan(
      id: id ?? this.id,
      nomor: nomor ?? this.nomor,
      kategori: kategori ?? this.kategori,
      lokasi: lokasi ?? this.lokasi,
      deskripsi: deskripsi ?? this.deskripsi,
      waktu: waktu ?? this.waktu,
      status: status ?? this.status,
      nominal: nominal ?? this.nominal,
      isAnonim: isAnonim ?? this.isAnonim,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'nomor': nomor,
        'kategori': kategori,
        'lokasi': lokasi,
        'deskripsi': deskripsi,
        'waktu': waktu.toIso8601String(),
        'status': status,
        'nominal': nominal,
        'is_anonim': isAnonim ? 1 : 0,
      };

  factory Laporan.fromMap(Map<String, Object?> map) => Laporan(
        id: map['id'] as int?,
        nomor: map['nomor'] as String,
        kategori: map['kategori'] as String,
        lokasi: map['lokasi'] as String,
        deskripsi: map['deskripsi'] as String,
        waktu: DateTime.tryParse(map['waktu'] as String? ?? '') ?? DateTime.now(),
        status: map['status'] as String? ?? 'Menunggu verifikasi',
        nominal: (map['nominal'] as num?)?.toInt() ?? 0,
        isAnonim: (map['is_anonim'] as int? ?? 1) == 1,
      );
}
