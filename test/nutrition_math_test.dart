import 'package:flutter_test/flutter_test.dart';
import 'package:healthlife/src/features/nutrition/data/model/daily_target_model.dart';
import 'package:healthlife/src/features/nutrition/data/model/food_model.dart';
import 'package:healthlife/src/features/nutrition/data/utils/nutrition_math.dart';

void main() {
  group('normalizeVietnamese', () {
    test('bỏ dấu + hạ chữ thường', () {
      expect(normalizeVietnamese('Phở Bò'), 'pho bo');
      expect(normalizeVietnamese('Bánh mì ốp la'), 'banh mi op la');
      expect(normalizeVietnamese('CÀ PHÊ SỮA ĐÁ'), 'ca phe sua da');
      expect(normalizeVietnamese('ỔM NGƯỜI'), 'om nguoi');
    });

    test('gộp khoảng trắng thừa', () {
      expect(normalizeVietnamese('  Phở   Bò  '), 'pho bo');
    });
  });

  group('DailyTargetModel', () {
    test('BMR nam: 10*60 + 6.25*170 - 5*25 + 5, x1.2, round 10', () {
      final t = DailyTargetModel.fromProfile(
        heightCm: 170,
        weightKg: 60,
        ageYears: 25,
        gender: 'male',
      );
      expect(t.calo, 1850);
    });

    test('BMR nữ trừ 161', () {
      final t = DailyTargetModel.fromProfile(
        heightCm: 170,
        weightKg: 60,
        ageYears: 25,
        gender: 'female',
      );
      expect(t.calo, 1650);
    });

    test('thiếu hồ sơ -> fallback 2000', () {
      expect(DailyTargetModel.fromProfile().calo, 2000);
    });

    test('chia nhỏ macros theo tỉ lệ 20/25/55', () {
      final t = DailyTargetModel.fromCalories(2200);
      expect(t.calo, 2200);
      expect(t.protein, closeTo(110, 0.01)); // 2200*0.2/4
      expect(t.fat, closeTo(61.11, 0.01)); // 2200*0.25/9
      expect(t.carb, closeTo(302.5, 0.01)); // 2200*0.55/4
      expect(t.fiber, 25);
    });
  });

  group('FoodNutrients scale theo gram', () {
    const food = FoodModel(
      id: 'pho_bo',
      name: 'Phở bò',
      nameSearch: 'pho bo',
      type: 'dish',
      group: 'Món nước',
      servingG: 500,
      calo: 380,
      protein: 21,
      fat: 12,
      carb: 48,
      fiber: 2,
    );

    test('grams = serving_g => đúng giá trị gốc', () {
      final n = food.nutrientsFor(500);
      expect(n.calo, 380);
      expect(n.protein, 21);
      expect(n.fat, 12);
      expect(n.carb, 48);
    });

    test('grams = nửa serving => chia đôi', () {
      final n = food.nutrientsFor(250).rounded();
      expect(n.calo, 190);
      expect(n.protein, 10.5);
      expect(n.fat, 6);
      expect(n.carb, 24);
    });

    test('phanso: 0 gram', () {
      final n = food.nutrientsFor(0);
      expect(n.calo, 0);
    });
  });
}