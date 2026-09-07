import 'package:flutter/material.dart';
import '../../../../../generated/assets.gen.dart';

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
        padding: const EdgeInsets.only(left: 12.0, top: 12.0, right: 8.0, bottom: 8.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF0F0),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: const Color(0xFFE5B8B7), width: 1.2),
        ),
        child: Stack(
          children: [
            // 1. Tiêu đề
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17.0,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
            ),

            // 2. Hình ảnh
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Nếu truyền 1 ảnh
                  if (iconAsset != null)
                    iconAsset!.image(
                        width: 63.0,
                        height: 63.0,
                        fit: BoxFit.contain
                    ),

                  // Nếu truyền mảng 2 ảnh trở lên
                  if (iconAssets != null)
                    ...iconAssets!.map((asset) => Padding(
                      padding: const EdgeInsets.only(left: 1.0),
                      child: asset.image(
                          width: 58.0,
                          height: 58.0,
                          fit: BoxFit.contain
                      ),
                    )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}