import '../datasources/medicine_remote_data_source.dart';
import '../model/medicine_model.dart';

class MedicineRepository {
  final MedicineRemoteDataSource _remoteDataSource;

  MedicineRepository(this._remoteDataSource);

  Future<List<MedicineModel>> searchMedicines(String query) {
    return _remoteDataSource.searchMedicines(query);
  }
}