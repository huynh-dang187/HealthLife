import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../generated/assets.gen.dart';
import '../../../../common/constants/colors.dart';
import '../cubit/food_scan_cubit.dart';

class FoodScanCameraSection extends StatelessWidget {
  final File? image;

  const FoodScanCameraSection({super.key, this.image});

  void _showImageSourceBottomSheet(BuildContext context) {
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
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF4856D0),
              ),
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
    return SizedBox(
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
              border: Border.all(
                color: const Color(0xFFE8D5D5),
                width: 1.5,
              ),
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.file(
                      image!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Assets.png.icFrame.image(
                            fit: BoxFit.contain,
errorBuilder: (_, _, _) => Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF234433),
                                  width: 2,
                                ),
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
                                errorBuilder: (_, _, _) => const Icon(
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
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
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
              onTap: () => _showImageSourceBottomSheet(context),
              child: Assets.png.icButtoncam.image(
                width: 80,
                height: 80,
                errorBuilder: (_, _, _) => Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFF234433),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: UIColors.white,
                    size: 36,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}