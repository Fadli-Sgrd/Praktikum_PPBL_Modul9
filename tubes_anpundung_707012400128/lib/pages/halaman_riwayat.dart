import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../cubit/laporan_cubit.dart';
import '../helpers/hive_helper.dart';
import '../models/laporan.dart';
import '../models/pantauan_laporan.dart';

class HalamanRiwayat extends StatelessWidget {
  const HalamanRiwayat({super.key});

  Future<void> _dialogUbahLaporan(BuildContext context, Laporan item) async {
    final deskripsiController = TextEditingController(text: item.deskripsi);
    final lokasiController = TextEditingController(text: item.lokasi);
    String statusTerpilih = item.status;

    final daftarStatus = [
      'Menunggu verifikasi',
      'Sedang ditinjau',
      'Terverifikasi',
      'Selesai',
    ];

    final hasil = await showDialog<Laporan>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Koreksi Laporan ${item.nomor}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Status Laporan:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: statusTerpilih,
                  items: daftarStatus
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => statusTerpilih = val);
                  },
                ),
                const SizedBox(height: 14),
                const Text('Lokasi:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: lokasiController,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
                const SizedBox(height: 14),
                const Text('Deskripsi:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: deskripsiController,
                  maxLines: 3,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogCtx,
                  item.copyWith(
                    status: statusTerpilih,
                    lokasi: lokasiController.text.trim(),
                    deskripsi: deskripsiController.text.trim(),
                  ),
                );
              },
              child: const Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );

    deskripsiController.dispose();
    lokasiController.dispose();

    if (hasil != null && context.mounted) {
      await context.read<LaporanCubit>().ubahLaporan(hasil);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan berhasil diperbarui')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<LaporanCubit, List<Laporan>>(
        builder: (context, laporan) => RefreshIndicator(
          onRefresh: () => context.read<LaporanCubit>().muatLaporan(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Riwayat Laporan',
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Muat ulang data',
                    onPressed: () => context.read<LaporanCubit>().muatLaporan(),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                'Data tersimpan permanen.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.storage_rounded,
                        size: 30, color: Color(0xFF087E68)),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total laporan',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                          Text('${laporan.length} laporan',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const Icon(Icons.shield_outlined, color: Color(0xFF087E68)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (laporan.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(
                    child: Text('Belum ada laporan tersimpan.'),
                  ),
                )
              else
                ...laporan.map(
                  (item) => Dismissible(
                    key: ValueKey(item.id ?? item.nomor),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.delete_outline, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    onDismissed: (_) {
                      if (item.id != null) {
                        context.read<LaporanCubit>().hapusLaporan(item.id!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Laporan ${item.nomor} dihapus dari SQLite.'),
                          ),
                        );
                      }
                    },
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _dialogUbahLaporan(context, item),
                      child: _KartuLaporan(laporan: item),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KartuLaporan extends StatelessWidget {
  const _KartuLaporan({required this.laporan});
  final Laporan laporan;

  @override
  Widget build(BuildContext context) {
    final statusSelesai = laporan.status == 'Terverifikasi' || laporan.status == 'Selesai';
    final tanggal =
        '${laporan.waktu.day.toString().padLeft(2, '0')}/${laporan.waktu.month.toString().padLeft(2, '0')}/${laporan.waktu.year}';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(laporan.kategori,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      if (laporan.nominal > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Rp ${laporan.nominal}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusSelesai
                        ? const Color(0xFFE4F4E9)
                        : const Color(0xFFFFF1DC),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    laporan.status,
                    style: TextStyle(
                      color: statusSelesai
                          ? const Color(0xFF267545)
                          : const Color(0xFF9B6413),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ValueListenableBuilder<Box<PantauanLaporan>>(
                  valueListenable: HiveHelper.box.listenable(),
                  builder: (context, box, _) {
                    final isDipantau = box.containsKey(laporan.nomor);
                    return IconButton(
                      icon: Icon(
                        isDipantau ? Icons.bookmark : Icons.bookmark_border,
                        color: isDipantau ? const Color(0xFF1976D2) : Colors.grey,
                      ),
                      tooltip: isDipantau
                          ? 'Hapus dari Pantauan (Hive)'
                          : 'Pantau Laporan (Hive)',
                      onPressed: () async {
                        final pantauan = PantauanLaporan(
                          nomorLaporan: laporan.nomor,
                          kategori: laporan.kategori,
                          lokasi: laporan.lokasi,
                          deskripsi: laporan.deskripsi,
                          nominal: laporan.nominal,
                          status: laporan.status,
                          waktu: laporan.waktu.toIso8601String(),
                        );
                        await HiveHelper.instance.togglePantauan(pantauan);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isDipantau
                                  ? 'Laporan ${laporan.nomor} dihapus dari Pantauan (Hive).'
                                  : 'Laporan ${laporan.nomor} ditambahkan ke Pantauan (Hive).'),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              laporan.deskripsi,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Expanded(
                    child: Text(laporan.lokasi,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ))),
                Text('$tanggal · ${laporan.nomor}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
