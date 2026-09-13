import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../generated/assets.gen.dart';
import '../../../../common/constants/colors.dart';
import '../../data/models/food_nutrition_model.dart';
import '../cubit/food_scan_cubit.dart';
import '../cubit/food_scan_state.dart';

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

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) => Container(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF4856D0)),
              title: Text('camera'.tr()),
              onTap: () {
                Navigator.maybePop(bottomSheetContext);
                context.read<FoodScanCubit>().pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF4856D0)),
              title: Text('gallery'.tr()),
              onTap: () {
                Navigator.maybePop(bottomSheetContext);
                context.read<FoodScanCubit>().pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
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
              final isLoading = state.isLoading;
              final errorMessage = state.errorMessage;
              final nutritionResult = state.nutritionResult;
              final selectedImage = state.selectedImage;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Assets.svg.icArrowLeft.svg(
                            colorFilter: const ColorFilter.mode(UIColors.black, BlendMode.srcIn),
                          ),
                          onPressed: () => Navigator.maybePop(context),
                        ),
                        Expanded(
                          child: Text(
                            'food_scan_title'.tr(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: UIColors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      height: 360,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 320,
                            margin: const EdgeInsets.only(bottom: 40),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF0F0),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFFE8D5D5), width: 1.5),
                            ),
                            child: selectedImage != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.file(selectedImage, fit: BoxFit.cover),
                            )
                                : Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Assets.png.icFrame.image(
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: const Color(0xFF234433), width: 2),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Assets.png.icCam.image(
                                          width: 85,
                                          height: 85,
                                          errorBuilder: (_, __, ___) => const Icon(
                                            Icons.camera_alt,
                                            size: 64,
                                            color: Color(0xFF666666),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'scan_guide_main'.tr(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: UIColors.black,
                                            height: 1.3,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'scan_guide_sub'.tr(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _showImageSourceBottomSheet,
                              child: Assets.png.icButtoncam.image(
                                width: 80,
                                height: 80,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 80,
                                  height: 80,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF234433),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt, color: UIColors.white, size: 36),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'manual_input_title'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEBEBEB),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _textController,
                              style: const TextStyle(color: UIColors.black, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'manual_input_hint'.tr(),
                                prefixIcon: const Icon(Icons.text_fields, color: Colors.black54),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () => context.read<FoodScanCubit>().analyzeText(_textController.text),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4856D0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            icon: Assets.png.icFind.image(
                              width: 20,
                              height: 20,
                            ),
                            label: Text(
                              'analyze_button'.tr(),
                              style: const TextStyle(color: UIColors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF0F0),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE8D5D5), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'nutrition_result_title'.tr(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 12),

                          if (isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                errorMessage,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                              ),
                            )
                          else if (nutritionResult != null) ...[
                              Text(
                                nutritionResult.foodName ?? 'default_food_name'.tr(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF234433),
                                ),
                              ),
                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  _buildNutrientChip('calories'.tr(), '${nutritionResult.calories ?? 0} kcal', Colors.orange),
                                  _buildNutrientChip('protein'.tr(), '${nutritionResult.proteinG ?? 0}g', Colors.blue),
                                  _buildNutrientChip('fat'.tr(), '${nutritionResult.fatG ?? 0}g', Colors.red),
                                  _buildNutrientChip('carbs'.tr(), '${nutritionResult.carbsG ?? 0}g', Colors.green),
                                ],
                              ),
                              const SizedBox(height: 16),

                              if (nutritionResult.assessment != null && nutritionResult.assessment!.isNotEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: UIColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF234433).withOpacity(0.3)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.rate_review, size: 18, color: Color(0xFF234433)),
                                          const SizedBox(width: 6),
                                          Text(
                                            'nutrition_assessment'.tr(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Color(0xFF234433),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        nutritionResult.assessment!,
                                        style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.3),
                                      ),
                                    ],
                                  ),
                                ),
                            ] else
                              const SizedBox(height: 40),

                          const SizedBox(height: 16),
                          Text(
                            'disclaimer_note'.tr(),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
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

  Widget _buildNutrientChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}