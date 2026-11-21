import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/pantauan_cubit.dart';
import '../helpers/hive_helper.dart';
import '../helpers/pengaturan_helper.dart';
import '../models/pembacaan_sensor.dart';
import '../widgets/sensor_card.dart';
import '../widgets/theme_toggle_button.dart';

class DashboardSensorPage extends StatefulWidget {
  const DashboardSensorPage({super.key});

  @override
  State<DashboardSensorPage> createState() => _DashboardSensorPageState();
}

class _DashboardSensorPageState extends State<DashboardSensorPage> {
  Map<String, double> _ambangBatas = {};

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    _ambangBatas = await PengaturanHelper.muatSemuaAmbangBatas();
    final box = HiveHelper.box;
    final terbaru = <String, PembacaanSensor>{};
    // Iterasi dari yang paling baru
    final list = box.values.toList()..sort((a, b) => b.waktu.compareTo(a.waktu));
    for (final item in list) {
      terbaru.putIfAbsent(item.jenisSensor, () => item);
    }
    if (mounted) {
      context.read<PantauanCubit>().muatPembacaanTerkini(terbaru.values.toList());
      setState(() {});
    }
  }

  String _hitungStatusRingkasan(List<PembacaanSensor> items) {
    if (items.isEmpty) return 'AMAN';
    var level = 0;
    for (final item in items) {
      final status = PengaturanHelper.hitungStatusSiaga(
          item.jenisSensor, item.nilai, _ambangBatas);
      if (status == 'Siaga') {
        level = 2;
      } else if (status == 'Waspada' && level < 1) {
        level = 1;
      }
    }
    return switch (level) { 2 => 'SIAGA', 1 => 'WASPADA', _ => 'AMAN' };
  }

  Color _warnaStatus(String status) => switch (status) {
        'SIAGA' => Colors.red,
        'WASPADA' => Colors.orange,
        _ => Colors.green,
      };

  Future<void> _tambahPembacaan(BuildContext context) async {
    final nilaiController = TextEditingController();
    final lokasiController = TextEditingController(text: 'Pos Utama');
    var jenis = 'ketinggian_air';
    final hasil = await showDialog<PembacaanSensor>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Input pembacaan sensor'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: jenis,
                decoration: const InputDecoration(labelText: 'Jenis sensor'),
                items: const [
                  DropdownMenuItem(value: 'ketinggian_air', child: Text('Ketinggian air (cm)')),
                  DropdownMenuItem(value: 'pergeseran_tanah', child: Text('Pergeseran tanah (mm)')),
                  DropdownMenuItem(value: 'curah_hujan', child: Text('Curah hujan (mm/jam)')),
                ],
                onChanged: (value) => setDialogState(() => jenis = value ?? jenis),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nilaiController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Nilai sensor'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: lokasiController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Lokasi pos pemantauan'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
            FilledButton(
              onPressed: () {
                final nilai = double.tryParse(nilaiController.text.trim());
                final lokasi = lokasiController.text.trim();
                if (nilai == null || lokasi.isEmpty) return;
                Navigator.pop(
                  dialogContext,
                  PembacaanSensor(
                    id: 'sensor_${DateTime.now().millisecondsSinceEpoch}',
                    jenisSensor: jenis,
                    nilai: nilai,
                    lokasiPos: lokasi,
                    waktu: DateTime.now().toIso8601String(),
                  ),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
    nilaiController.dispose();
    lokasiController.dispose();
    if (hasil == null || !context.mounted) return;

    try {
      await HiveHelper.instance.tambahPembacaan(hasil);
      if (!context.mounted) return;
      context.read<PantauanCubit>().tandaiPembacaanBaru(hasil);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembacaan tersimpan secara lokal ke Hive.')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan pembacaan: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PantauanCubit, List<PembacaanSensor>>(
      builder: (context, pembacaan) {
        final statusSiaga = _hitungStatusRingkasan(pembacaan);
        final warna = _warnaStatus(statusSiaga);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Pantauan Sensor'),
            actions: [
              Chip(
                backgroundColor: warna.withAlpha(50),
                side: BorderSide(color: warna),
                avatar: CircleAvatar(
                  backgroundColor: warna,
                  radius: 6,
                ),
                label: Text(
                  statusSiaga,
                  style: TextStyle(
                    color: warna,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const ThemeToggleButton(),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _tambahPembacaan(context),
            icon: const Icon(Icons.add),
            label: const Text('Input sensor'),
          ),
          body: pembacaan.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Belum ada pembacaan sensor. Masukkan pembacaan untuk menyimpannya ke Hive.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.only(top: 12, bottom: 88),
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Text(
                        'Pembacaan terbaru per sensor',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    for (final item in pembacaan) SensorCard(pembacaan: item),
                  ],
                ),
        );
      },
    );
  }
}
