import 'package:flutter/material.dart';

import '../models/pembacaan_sensor.dart';

class SensorCard extends StatelessWidget {
  final PembacaanSensor pembacaan;
  const SensorCard({super.key, required this.pembacaan});

  String get label => switch (pembacaan.jenisSensor) {
        'ketinggian_air' => 'Ketinggian Air',
        'pergeseran_tanah' => 'Pergeseran Tanah',
        'curah_hujan' => 'Curah Hujan',
        _ => pembacaan.jenisSensor,
      };

  String get unit => switch (pembacaan.jenisSensor) {
        'ketinggian_air' => 'cm',
        'pergeseran_tanah' => 'mm',
        _ => 'mm/jam',
      };

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.sensors)),
          title: Text(label),
          subtitle: Text('Pos ${pembacaan.lokasiPos}'),
          trailing: Text(
            '${pembacaan.nilai} $unit',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      );
}
