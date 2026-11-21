import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/pembacaan_sensor.dart';

class PantauanCubit extends Cubit<List<PembacaanSensor>> {
  PantauanCubit() : super(const []);

  void muatPembacaanTerkini(List<PembacaanSensor> pembacaan) {
    emit(pembacaan);
  }

  void tandaiPembacaanBaru(PembacaanSensor pembacaan) {
    emit([
      pembacaan,
      ...state.where((item) => item.jenisSensor != pembacaan.jenisSensor),
    ]);
  }
}
