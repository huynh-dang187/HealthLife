import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../common/constants/colors.dart';
import '../../domain/entities/food_nutrition.dart';

class FoodScanResultSection extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final FoodNutrition? nutritionResult;

  const FoodScanResultSection({
    super.key,
    required this.isLoading,
    this.errorMessage,
    this.nutritionResult,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF0F0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8D5D5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'nutrition_result_title'.tr(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
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
                errorMessage!,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 14,
                ),
              ),
            )
          else if (nutritionResult != null) ...[
            Text(
              nutritionResult!.foodName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF234433),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                _NutrientChip(
                  label: 'calories'.tr(),
                  value: '${nutritionResult!.calories} kcal',
                  color: Colors.orange,
                ),
                _NutrientChip(
                  label: 'protein'.tr(),
                  value: '${nutritionResult!.proteinG}g',
                  color: Colors.blue,
                ),
                _NutrientChip(
                  label: 'fat'.tr(),
                  value: '${nutritionResult!.fatG}g',
                  color: Colors.red,
                ),
                _NutrientChip(
                  label: 'carbs'.tr(),
                  value: '${nutritionResult!.carbsG}g',
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (nutritionResult!.assessment.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: UIColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(
                      0xFF234433,
                    ).withValues(alpha: 30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.rate_review,
                          size: 18,
                          color: Color(0xFF234433),
                        ),
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
                      nutritionResult!.assessment,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
          ] else
            const SizedBox(height: 40),

          const SizedBox(height: 16),
          Text(
            'disclaimer_note'.tr(),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _NutrientChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _NutrientChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 10)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}