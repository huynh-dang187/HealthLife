import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../shared/enums/bloc_status.dart';
import '../../data/datasources/gemini_scan_remote_data_source.dart';
import 'food_scan_state.dart';

class FoodScanCubit extends Cubit<FoodScanState> {
  final GeminiScanRemoteDataSource _dataSource;
  final ImagePicker _picker;

  FoodScanCubit({
    GeminiScanRemoteDataSource? dataSource,
    ImagePicker? picker,
  })  : _dataSource = dataSource ?? GeminiScanRemoteDataSource(),
        _picker = picker ?? ImagePicker(),
        super(const FoodScanState());

  Future<void> pickImageFromCamera() async {
    await _pickImage(ImageSource.camera);
  }

  Future<void> pickImageFromGallery() async {
    await _pickImage(ImageSource.gallery);
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;

    final imageFile = File(pickedFile.path);
    emit(state.copyWith(
      status: BlocStatus.loading,
      selectedImage: imageFile,
      errorMessage: null,
    ));

    try {
      final result = await _dataSource.analyzeFoodImage(pickedFile.path);
      if (result.isFood) {
        emit(state.copyWith(
          status: BlocStatus.success,
          nutritionResult: result,
        ));
      } else {
        emit(state.copyWith(
          status: BlocStatus.failure,
          errorMessage: result.errorMessage ?? 'Không thể nhận diện món ăn.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BlocStatus.failure,
        errorMessage: 'Lỗi phân tích: $e',
      ));
    }
  }

  Future<void> analyzeText(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    emit(state.copyWith(
      status: BlocStatus.loading,
      errorMessage: null,
    ));

    try {
      final result = await _dataSource.analyzeFoodText(query);
      if (result.isFood) {
        emit(state.copyWith(
          status: BlocStatus.success,
          nutritionResult: result,
        ));
      } else {
        emit(state.copyWith(
          status: BlocStatus.failure,
          errorMessage: result.errorMessage ?? 'Không tìm thấy thông tin món ăn.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BlocStatus.failure,
        errorMessage: 'Lỗi phân tích: $e',
      ));
    }
  }
}