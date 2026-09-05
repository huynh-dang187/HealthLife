import 'package:flutter/material.dart';
import '../../../../../generated/assets.gen.dart';
import '../../../../core/presentation/widgets/text.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  final AssetGenImage? iconAsset;
  final List<AssetGenImage>? iconAssets;

  const CategoryCard({
    super.key,
    required this.title,
    required this.onTap,
    this.iconAsset,
    this.iconAssets,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 12.0, top: 10.0, right: 8.0, bottom: 8.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF0F0),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: const Color(0xFFE5B8B7), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Tiêu đề
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.topLeft,
                child: AppText.bold(
                  title.toUpperCase(),
                  fontSize: 16.0,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  height: 1.1,
                  maxLines: 2,
                ),
              ),
            ),

            // 2. Hình ảnh
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (iconAsset != null)
                      Flexible(
                        child: iconAsset!.image(
                          height: 58.0,
                          fit: BoxFit.contain,
                        ),
                      ),
                    if (iconAssets != null)
                      ...iconAssets!.map((asset) => Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 1.0),
                          child: asset.image(
                            height: 52.0,
                            fit: BoxFit.contain,
                          ),
                        ),
                      )),
                  ],
                ),
              ),
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