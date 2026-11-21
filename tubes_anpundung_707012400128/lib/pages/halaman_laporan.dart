import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/laporan_cubit.dart';

class HalamanLaporan extends StatefulWidget {
  const HalamanLaporan({super.key});

  @override
  State<HalamanLaporan> createState() => _HalamanLaporanState();
}

class _HalamanLaporanState extends State<HalamanLaporan> {
  final _formKey = GlobalKey<FormState>();
  final _lokasiController = TextEditingController();
  final _nominalController = TextEditingController();
  final _deskripsiController = TextEditingController();
  String _kategori = 'Pelayanan publik';
  bool _anonim = true;

  static const _kategoriLaporan = [
    'Pelayanan publik',
    'Perizinan',
    'Parkir',
    'Pendidikan',
    'Lainnya',
  ];

  @override
  void dispose() {
    _lokasiController.dispose();
    _nominalController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _kirimLaporan() async {
    if (!_formKey.currentState!.validate()) return;
    final nominal = int.tryParse(_nominalController.text.trim()) ?? 0;

    await context.read<LaporanCubit>().tambahLaporan(
      kategori: _kategori,
      lokasi: _lokasiController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
      nominal: nominal,
      isAnonim: _anonim,
    );

    _lokasiController.clear();
    _nominalController.clear();
    _deskripsiController.clear();

    if (!mounted) return;
    setState(() {
      _kategori = _kategoriLaporan.first;
      _anonim = true;
    });
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Laporan berhasil disimpan'),
        backgroundColor: Color(0xFF087E68),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          const Text(
            'Buat Laporan',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 7),
          Text(
            'Ceritakan kejadian pungutan liar yang kamu temui.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label('Kategori kejadian'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _kategori,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: _kategoriLaporan
                          .map(
                            (kategori) => DropdownMenuItem(
                              value: kategori,
                              child: Text(kategori),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _kategori = value);
                      },
                    ),
                    const SizedBox(height: 18),
                    const _Label('Lokasi kejadian'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _lokasiController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: Kecamatan Coblong',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Lokasi perlu diisi.'
                          : null,
                    ),
                    const SizedBox(height: 18),
                    const _Label('Perkiraan nominal pungli (opsional)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nominalController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: 50000',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _Label('Kronologi singkat'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _deskripsiController,
                      minLines: 4,
                      maxLines: 6,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        hintText: 'Jelaskan apa yang terjadi, kapan, dan oknum/layanan terkait.',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) =>
                          value == null || value.trim().length < 10
                          ? 'Ceritakan kejadian minimal 10 karakter.'
                          : null,
                    ),
                    const SizedBox(height: 9),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _kirimLaporan,
                        icon: const Icon(Icons.send_rounded),
                        label: const Text('Kirim'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF087E68),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(fontWeight: FontWeight.w600));
}
