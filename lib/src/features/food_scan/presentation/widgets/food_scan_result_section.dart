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
        color: UIColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: UIColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: UIColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'nutrition_result_title'.tr(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: UIColors.text,
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
                color: UIColors.text,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                _NutrientChip(
                  label: 'calories'.tr(),
                  value: '${nutritionResult!.calories} kcal',
                  color: const Color(0xFFF97316),
                ),
                _NutrientChip(
                  label: 'protein'.tr(),
                  value: '${nutritionResult!.proteinG}g',
                  color: UIColors.pink,
                ),
                _NutrientChip(
                  label: 'fat'.tr(),
                  value: '${nutritionResult!.fatG}g',
                  color: const Color(0xFFE9A13B),
                ),
                _NutrientChip(
                  label: 'carbs'.tr(),
                  value: '${nutritionResult!.carbsG}g',
                  color: const Color(0xFF2563EB),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (nutritionResult!.assessment.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6FAF7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF34C759).withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.rate_review_outlined,
                          size: 18,
                          color: Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'nutrition_assessment'.tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      nutritionResult!.assessment,
                      style: const TextStyle(
                        fontSize: 13,
                        color: UIColors.text,
                        height: 1.45,
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
              color: UIColors.textBody,
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
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: UIColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}