import 'package:flutter/material.dart';
import '../../domain/entities/food_nutrition.dart';

class NutritionResultCard extends StatelessWidget {
  final FoodNutrition? data;

  const NutritionResultCard({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF0EF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pink.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kết quả dinh dưỡng',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Text(
            'Năng lượng: ${data?.calories.toStringAsFixed(0) ?? 0} kcal',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Protein: ${data?.proteinG.toStringAsFixed(0) ?? 0}g',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Fat: ${data?.fatG.toStringAsFixed(0) ?? 0}g',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Carbohydrates: ${data?.carbsG.toStringAsFixed(0) ?? 0}g',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            '(! ) Lưu ý: Dữ liệu tính toán dựa trên mức trung bình',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}