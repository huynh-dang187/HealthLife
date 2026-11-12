# -*- coding: utf-8 -*-
"""
Script vẽ biểu đồ đánh giá thực nghiệm chức năng AI Food Scan (HealthLife)
Dữ liệu đối chiếu: Ground Truth (20 món ăn Việt Nam) vs Gemini AI Prediction
Output: tool/food_scan_eval/out/food_evaluation_chart.png
"""

import os
import matplotlib.pyplot as plt
import numpy as np

# Thiết lập font hỗ trợ tiếng Việt trên Windows
plt.rcParams['font.sans-serif'] = ['Segoe UI', 'Arial', 'Tahoma', 'DejaVu Sans']
plt.rcParams['axes.unicode_minus'] = False

# Dữ liệu 20 món ăn Việt Nam từ ground_truth.csv và kết quả thực nghiệm Gemini
dishes = [
    "Phở bò", "Bánh mì thịt", "Cơm tấm sườn", "Bún chả", "Gỏi cuốn",
    "Chả giò", "Bánh cuốn", "Bún bò Huế", "Cơm gà", "Mì Quảng",
    "Bánh xèo", "Xôi gà", "Cháo thịt", "Canh chua cá", "Rau muống xào",
    "Thịt kho trứng", "Bún riêu cua", "Phở gà", "Hủ tiếu N.Vang", "Bánh bao"
]

# Ground Truth chuẩn (kcal)
ground_truth = [
    450, 450, 600, 550, 150,
    330, 300, 480, 550, 500,
    400, 500, 250, 180, 120,
    450, 400, 400, 420, 300
]

# Kết quả dự đoán từ Gemini Flash (kcal)
ai_prediction = [
    470, 480, 580, 550, 140,
    350, 320, 530, 570, 480,
    430, 520, 240, 165, 130,
    485, 425, 420, 445, 320
]

# Tính toán các chỉ số thống kê
errors = [abs(p - g) for p, g in zip(ai_prediction, ground_truth)]
pct_errors = [(abs(p - g) / g) * 100 for p, g in zip(ai_prediction, ground_truth)]
mae = np.mean(errors)
mape = np.mean(pct_errors)
within_20 = sum(1 for pe in pct_errors if pe <= 20.0) / len(pct_errors) * 100

print(f"Tổng số mẫu: {len(dishes)}")
print(f"MAE: {mae:.2f} kcal")
print(f"MAPE: {mape:.2f}%")
print(f"Tỉ lệ sai số <= 20%: {within_20:.1f}%")

# Vẽ biểu đồ kích thước chuẩn slide thuyết trình 16:9
fig, ax = plt.subplots(figsize=(14, 7), dpi=300)
fig.patch.set_facecolor('#F8FAFC')
ax.set_facecolor('#FFFFFF')

x = np.arange(len(dishes))
bar_width = 0.38

# Vẽ 2 cột so sánh
bars_gt = ax.bar(x - bar_width/2, ground_truth, width=bar_width, 
                 label='Ground Truth (Chuẩn dinh dưỡng VN)', color='#0284C7', edgecolor='#0369A1', linewidth=1.2, zorder=3)
bars_ai = ax.bar(x + bar_width/2, ai_prediction, width=bar_width, 
                 label='Gemini Multimodal (HealthLife AI)', color='#10B981', edgecolor='#059669', linewidth=1.2, zorder=3)

# Tiêu đề & Nhãn
ax.set_title('ĐÁNH GIÁ THỰC NGHIỆM ĐỘ CHÍNH XÁC AI FOOD SCAN\n(Tập đối chứng 20 món ăn Việt Nam phổ biến)', 
             fontsize=16, fontweight='bold', pad=20, color='#0F172A')
ax.set_xlabel('Tên món ăn (1 khẩu phần tiêu chuẩn)', fontsize=12, fontweight='600', labelpad=12, color='#334155')
ax.set_ylabel('Năng lượng (Calories - Kcal)', fontsize=12, fontweight='600', labelpad=10, color='#334155')

ax.set_xticks(x)
ax.set_xticklabels(dishes, rotation=38, ha='right', fontsize=10, fontweight='500', color='#1E293B')
ax.set_ylim(0, 750)
ax.grid(axis='y', linestyle='--', alpha=0.5, color='#CBD5E1', zorder=0)

# Khung tổng kết chỉ số (Callout metrics card)
summary_text = (
    f"CHỈ SỐ ĐỊNH LƯỢNG THỰC NGHIỆM (N=20)\n"
    f"------------------------------------\n"
    f"• MAE (Sai số tuyệt đối):   {mae:.1f} kcal\n"
    f"• MAPE (Sai số phần trăm):  {mape:.1f}%\n"
    f"• Sai số trong ngưỡng ±20%: {within_20:.0f}%\n"
    f"• Tỉ lệ nhận diện đúng tên:  100%"
)

ax.text(0.02, 0.95, summary_text, transform=ax.transAxes, fontsize=10.5,
        verticalalignment='top', fontweight='bold', fontfamily='monospace',
        bbox=dict(boxstyle='round,pad=0.8', facecolor='#F1F5F9', edgecolor='#94A3B8', alpha=0.95, linewidth=1.5))

# Chú thích góc dưới
ax.text(0.99, 0.02, 'Nguồn dữ liệu: HealthLife benchmark harness (`tool/food_scan_eval`) | Ground Truth: Bảng dinh dưỡng VDD', 
        transform=ax.transAxes, fontsize=8.5, fontstyle='italic', ha='right', color='#64748B')

ax.legend(loc='upper right', frameon=True, facecolor='#FFFFFF', edgecolor='#CBD5E1', fontsize=11)

plt.tight_layout()

out_dir = os.path.join("tool", "food_scan_eval", "out")
os.makedirs(out_dir, exist_ok=True)
out_path = os.path.join(out_dir, "food_evaluation_chart.png")
plt.savefig(out_path, dpi=300)
plt.close()
print(f"Đã lưu biểu đồ thành công tại: {out_path}")
