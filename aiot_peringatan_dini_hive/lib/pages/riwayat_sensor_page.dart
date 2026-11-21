import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../helpers/hive_helper.dart';
import '../helpers/pengaturan_helper.dart';
import '../models/pembacaan_sensor.dart';

class RiwayatSensorPage extends StatefulWidget {
  const RiwayatSensorPage({super.key});

  @override
  State<RiwayatSensorPage> createState() => _RiwayatSensorPageState();
}

class _RiwayatSensorPageState extends State<RiwayatSensorPage> {
  Map<String, double> _ambangBatas = {};

  @override
  void initState() {
    super.initState();
    _muatBatas();
  }

  Future<void> _muatBatas() async {
    final batas = await PengaturanHelper.muatSemuaAmbangBatas();
    if (mounted) setState(() => _ambangBatas = batas);
  }

  String _statusRingkasan(List<PembacaanSensor> semua) {
    if (semua.isEmpty) return 'AMAN';
    final terbaru = <String, PembacaanSensor>{};
    for (final item in semua) {
      terbaru.putIfAbsent(item.jenisSensor, () => item);
    }
    var level = 0;
    for (final item in terbaru.values) {
      final s = PengaturanHelper.hitungStatusSiaga(
          item.jenisSensor, item.nilai, _ambangBatas);
      if (s == 'Siaga') {
        level = 2;
      } else if (s == 'Waspada' && level < 1) {
        level = 1;
      }
    }
    return switch (level) { 2 => 'SIAGA', 1 => 'WASPADA', _ => 'AMAN' };
  }

  Color _warnaStatus(String status) => switch (status) {
        'SIAGA' || 'Siaga' => Colors.red,
        'WASPADA' || 'Waspada' => Colors.orange,
        _ => Colors.green,
      };

  String _formatLabel(String jenis) => switch (jenis) {
        'ketinggian_air' => 'Ketinggian Air',
        'pergeseran_tanah' => 'Pergeseran Tanah',
        'curah_hujan' => 'Curah Hujan',
        _ => jenis,
      };

  String _formatSatuan(String jenis) => switch (jenis) {
        'ketinggian_air' => 'cm',
        'pergeseran_tanah' => 'mm',
        _ => 'mm/jam',
      };

  Future<void> _ubahNilai(PembacaanSensor item) async {
    final controller = TextEditingController(text: item.nilai.toString());
    final nilai = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Koreksi nilai sensor'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Nilai baru'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(
                context, double.tryParse(controller.text.trim())),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (nilai == null) return;
    item.nilai = nilai;
    await item.save();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nilai pembacaan berhasil dikoreksi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<PembacaanSensor>>(
      valueListenable: HiveHelper.box.listenable(),
      builder: (context, box, _) {
        final semua = box.values.toList()
          ..sort((a, b) => b.waktu.compareTo(a.waktu));
        final statusGlobal = _statusRingkasan(semua);
        final warnaGlobal = _warnaStatus(statusGlobal);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Riwayat Sensor'),
            actions: [
              Chip(
                backgroundColor: warnaGlobal.withAlpha(50),
                side: BorderSide(color: warnaGlobal),
                avatar: CircleAvatar(
                  backgroundColor: warnaGlobal,
                  radius: 6,
                ),
                label: Text(
                  statusGlobal,
                  style: TextStyle(
                    color: warnaGlobal,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: semua.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Belum ada riwayat pembacaan sensor pada Hive.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: semua.length,
                  itemBuilder: (context, index) {
                    final item = semua[index];
                    final statusItem = PengaturanHelper.hitungStatusSiaga(
                        item.jenisSensor, item.nilai, _ambangBatas);
                    final warnaItem = _warnaStatus(statusItem);

                    return Dismissible(
                      key: ValueKey(item.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) async {
                        await item.delete();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pembacaan sensor berhasil dihapus dari Hive.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: warnaItem.withAlpha(40),
                            child: Icon(Icons.sensors, color: warnaItem),
                          ),
                          title: Row(
                            children: [
                              Text(
                                _formatLabel(item.jenisSensor),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: warnaItem.withAlpha(40),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: warnaItem, width: 0.8),
                                ),
                                child: Text(
                                  statusItem.toUpperCase(),
                                  style: TextStyle(
                                    color: warnaItem,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Nilai: ${item.nilai} ${_formatSatuan(item.jenisSensor)} • Pos ${item.lokasiPos}'),
                              Text(
                                item.waktu.length >= 19
                                    ? item.waktu.substring(0, 19).replaceAll('T', ' ')
                                    : item.waktu,
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            tooltip: 'Koreksi Nilai',
                            onPressed: () => _ubahNilai(item),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
