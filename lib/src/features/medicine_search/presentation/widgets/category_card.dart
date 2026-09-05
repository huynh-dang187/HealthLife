import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? imagePath;         // Dành cho 1 ảnh đơn
  final List<String>? imagePaths;  // Dành cho danh sách 2 hoặc nhiều ảnh nằm ngang
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    this.icon,
    this.imagePath,
    this.imagePaths,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F0),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5B8B7), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 1. Tiêu đề: Chữ to, màu đen, siêu đậm (w900)
            Text(
              title,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                height: 1.15,
                letterSpacing: 0.2,
              ),
            ),

            // 2. Vùng hiển thị ảnh/Icon căn góc dưới bên phải
            Align(
              alignment: Alignment.bottomRight,
              child: _buildImagesOrIcon(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesOrIcon() {
    // Trường hợp 1: Truyền danh sách nhiều ảnh nằm ngang
    if (imagePaths != null && imagePaths!.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: imagePaths!.map((path) {
          return Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Image.asset(
              path,
              height: 58, // Tăng kích thước ảnh lớn
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
            ),
          );
        }).toList(),
      );
    }

    // Trường hợp 2: Truyền 1 ảnh đơn
    if (imagePath != null) {
      return Image.asset(
        imagePath!,
        height: 68, // Tăng kích thước ảnh lớn
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
      );
    }

    // Trường hợp 3: Mặc định hiển thị Icon nếu chưa truyền ảnh
    return Icon(
      icon ?? Icons.medication,
      size: 45,
      color: const Color(0xFF8C4A4A),
    );
  }
}