# Đánh giá chức năng Food Scan (Gemini)

Bộ công cụ nhỏ để **đánh giá pipeline Food Scan của mình** trên một tập test có
đáp án (ground truth). Đây **không phải** "độ chính xác của model Gemini đã
train" — Gemini là model đóng của Google, mình không train và API không trả về
accuracy. Cái mình đo là **độ chính xác cho bài toán của mình** (ước lượng dinh
dưỡng món ăn Việt).

## Thành phần

| File | Mô tả |
|---|---|
| `ground_truth.csv` | Tập test: 20 món Việt phổ biến kèm giá trị dinh dưỡng tham chiếu |
| `evaluate_food_scan.dart` | Harness: gọi Gemini cho từng mẫu, so với đáp án, tính metric |
| `out/results.csv` | (sinh ra khi chạy) kết quả từng mẫu |
| `out/results.md` | (sinh ra khi chạy) bảng tổng kết để dán vào báo cáo |

## Cách chạy

Cần `GEMINI_API_KEY`. Chạy từ **thư mục gốc dự án**:

```powershell
$env:GEMINI_API_KEY="<key-cua-ban>"; fvm dart run tool/food_scan_eval/evaluate_food_scan.dart
```

Hoặc:

```powershell
fvm dart run tool/food_scan_eval/evaluate_food_scan.dart --api-key=<key-cua-ban>
```

## Định dạng `ground_truth.csv`

```
id,food_name,calories,protein_g,fat_g,carbs_g,image_path
```

- `food_name`: tên món (dùng cho chế độ text).
- `calories`, `protein_g`, `fat_g`, `carbs_g`: giá trị **đáp án** cho 1 khẩu phần.
- `image_path`: để trống để chạy bằng tên món (text). Nếu muốn test bằng ảnh,
  điền đường dẫn file ảnh (vd. `tool/food_scan_eval/images/pho_bo.jpg`) —
  harness sẽ tự dùng ảnh thay vì text.

## Metric được tính

- **Accuracy nhận diện tên món**: so khớp mờ (bỏ dấu, chấp nhận chứa nhau).
- **MAE / MAPE calories**: sai số tuyệt đối / phần trăm trung bình.
- **Tỉ lệ calories lệch trong ±20%**.
- **MAE protein / fat / carbs**.

## Lưu ý

- Giá trị dinh dưỡng trong `ground_truth.csv` là **giá trị tham chiếu ~1 khẩu
  phần**, gom từ nguồn dinh dưỡng phổ biến. Nếu có dữ liệu chuẩn hơn (bảng thành
  phần dinh dưỡng Việt Nam, nhãn bao bì), hãy cập nhật lại để kết quả chính xác.
- Chạy chế độ text (không ảnh) mất ~1–2 phút cho 20 mẫu.
- Muốn test bằng ảnh thật: tạo thư mục `tool/food_scan_eval/images/`, thêm ảnh và
  điền cột `image_path`.
