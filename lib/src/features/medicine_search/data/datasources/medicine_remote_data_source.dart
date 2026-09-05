import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/medicine_model.dart';

class MedicineRemoteDataSource {
  final SupabaseClient _client;

  MedicineRemoteDataSource(this._client);

  Future<List<MedicineModel>> searchMedicines(String query) async {
    // Gọi bảng 'medicines', tìm kiếm gần đúng (ilike) theo cột 'name'
    final response = await _client
        .from('medicines')
        .select()
        .ilike('name', '%$query%')
        .limit(20);

    return (response as List)
        .map((e) => MedicineModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}