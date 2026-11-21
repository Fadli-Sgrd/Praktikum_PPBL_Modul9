import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/theme_cubit.dart';
import '../helpers/pengaturan_helper.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  final _waspadaAirController = TextEditingController();
  final _siagaAirController = TextEditingController();
  final _waspadaTanahController = TextEditingController();
  final _siagaTanahController = TextEditingController();
  final _waspadaHujanController = TextEditingController();
  final _siagaHujanController = TextEditingController();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _muatPengaturan();
  }

  Future<void> _muatPengaturan() async {
    final batas = await PengaturanHelper.muatSemuaAmbangBatas();
    setState(() {
      _waspadaAirController.text =
          (batas[PengaturanHelper.keyBatasWaspadaAir] ?? 2.0).toString();
      _siagaAirController.text =
          (batas[PengaturanHelper.keyBatasSiagaAir] ?? 3.5).toString();

      _waspadaTanahController.text =
          (batas[PengaturanHelper.keyBatasWaspadaTanah] ?? 5.0).toString();
      _siagaTanahController.text =
          (batas[PengaturanHelper.keyBatasSiagaTanah] ?? 10.0).toString();

      _waspadaHujanController.text =
          (batas[PengaturanHelper.keyBatasWaspadaHujan] ?? 50.0).toString();
      _siagaHujanController.text =
          (batas[PengaturanHelper.keyBatasSiagaHujan] ?? 100.0).toString();
      _loading = false;
    });
  }

  Future<void> _simpanSemua() async {
    final wAir = double.tryParse(_waspadaAirController.text.trim());
    final sAir = double.tryParse(_siagaAirController.text.trim());
    final wTanah = double.tryParse(_waspadaTanahController.text.trim());
    final sTanah = double.tryParse(_siagaTanahController.text.trim());
    final wHujan = double.tryParse(_waspadaHujanController.text.trim());
    final sHujan = double.tryParse(_siagaHujanController.text.trim());

    if (wAir == null ||
        sAir == null ||
        wTanah == null ||
        sTanah == null ||
        wHujan == null ||
        sHujan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua nilai ambang batas harus berupa angka valid.')),
      );
      return;
    }

    await PengaturanHelper.simpanAmbangBatas(PengaturanHelper.keyBatasWaspadaAir, wAir);
    await PengaturanHelper.simpanAmbangBatas(PengaturanHelper.keyBatasSiagaAir, sAir);
    await PengaturanHelper.simpanAmbangBatas(PengaturanHelper.keyBatasWaspadaTanah, wTanah);
    await PengaturanHelper.simpanAmbangBatas(PengaturanHelper.keyBatasSiagaTanah, sTanah);
    await PengaturanHelper.simpanAmbangBatas(PengaturanHelper.keyBatasWaspadaHujan, wHujan);
    await PengaturanHelper.simpanAmbangBatas(PengaturanHelper.keyBatasSiagaHujan, sHujan);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ambang batas berhasil disimpan ke SharedPreferences.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _waspadaAirController.dispose();
    _siagaAirController.dispose();
    _waspadaTanahController.dispose();
    _siagaTanahController.dispose();
    _waspadaHujanController.dispose();
    _siagaHujanController.dispose();
    super.dispose();
  }

  Widget _buildSensorThresholdSection({
    required String judul,
    required String satuan,
    required TextEditingController waspadaCtrl,
    required TextEditingController siagaCtrl,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(judul, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: waspadaCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Batas Waspada ($satuan)',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: siagaCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Batas Siaga ($satuan)',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Ambang Batas'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              title: const Text('Mode Gelap'),
              value: isDark,
              onChanged: (_) => context.read<ThemeCubit>().toggle(),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ambang Batas Status Siaga (BPBD)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Nilai di bawah ini disimpan ke SharedPreferences dan digunakan untuk menentukan status bahaya bencana.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          _buildSensorThresholdSection(
            judul: 'Ketinggian Air Sungai',
            satuan: 'cm',
            waspadaCtrl: _waspadaAirController,
            siagaCtrl: _siagaAirController,
            icon: Icons.water,
          ),
          _buildSensorThresholdSection(
            judul: 'Pergeseran Tanah',
            satuan: 'mm',
            waspadaCtrl: _waspadaTanahController,
            siagaCtrl: _siagaTanahController,
            icon: Icons.landscape,
          ),
          _buildSensorThresholdSection(
            judul: 'Curah Hujan',
            satuan: 'mm/jam',
            waspadaCtrl: _waspadaHujanController,
            siagaCtrl: _siagaHujanController,
            icon: Icons.grain,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _simpanSemua,
            icon: const Icon(Icons.save),
            label: const Text('Simpan Ambang Batas'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
