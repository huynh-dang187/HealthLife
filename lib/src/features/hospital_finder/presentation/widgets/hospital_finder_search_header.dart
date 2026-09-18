import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../generated/assets.gen.dart';
import '../../../../common/constants/colors.dart';
import '../cubit/hospital_finder_cubit.dart';

class HospitalFinderSearchHeader extends StatelessWidget {
  const HospitalFinderSearchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  final cubit = context.read<HospitalFinderCubit>();
                  if (cubit.state.isQuickMenuOpen) {
                    cubit.toggleQuickMenu();
                  } else if (cubit.state.activePopupFacility != null) {
                    cubit.closeFacilityPopup();
                  } else {
                    Navigator.maybePop(context);
                  }
                },
                icon: Assets.svg.icArrowLeft.svg(
                  colorFilter: const ColorFilter.mode(
                    UIColors.black,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'search_title'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: UIColors.black,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: UIColors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFFE5B8B7),
                width: 1.5,
              ),
            ),
            child: TextField(
              onChanged: (value) =>
                  context.read<HospitalFinderCubit>().updateSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'search_hint'.tr(),
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Assets.png.icTimkiem.image(
                    width: 20,
                    height: 20,
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