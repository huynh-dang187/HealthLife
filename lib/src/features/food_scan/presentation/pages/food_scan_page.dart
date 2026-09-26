import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/constants/colors.dart';
import '../cubit/food_scan_cubit.dart';
import '../cubit/food_scan_state.dart';
import '../widgets/food_scan_camera_section.dart';
import '../widgets/food_scan_header.dart';
import '../widgets/food_scan_manual_input.dart';
import '../widgets/food_scan_result_section.dart';

class FoodScanPage extends StatelessWidget {
  const FoodScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FoodScanCubit(),
      child: const _FoodScanBody(),
    );
  }
}

class _FoodScanBody extends StatefulWidget {
  const _FoodScanBody();

  @override
  State<_FoodScanBody> createState() => _FoodScanBodyState();
}

class _FoodScanBodyState extends State<_FoodScanBody> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _analyzeText(String text) {
    context.read<FoodScanCubit>().analyzeText(text);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: UIColors.white,
      ),
      child: Scaffold(
        backgroundColor: UIColors.white,
        body: SafeArea(
          child: BlocBuilder<FoodScanCubit, FoodScanState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FoodScanHeader(),
                    const SizedBox(height: 16),

                    FoodScanCameraSection(image: state.selectedImage),
                    const SizedBox(height: 20),

                    FoodScanManualInput(
                      controller: _textController,
                      isLoading: state.isLoading,
                      onAnalyze: _analyzeText,
                    ),
                    const SizedBox(height: 20),

                    FoodScanResultSection(
                      isLoading: state.isLoading,
                      errorMessage: state.errorMessage,
                      nutritionResult: state.nutritionResult,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}