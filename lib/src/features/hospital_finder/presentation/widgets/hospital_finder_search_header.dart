import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:healthlife/generated/assets.gen.dart';
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
          // 1. Back Button and Title Row
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: Assets.svg.icArrowLeft.svg(
                  colorFilter: const ColorFilter.mode(
                    UIColors.black,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const Expanded(
                child: Text(
                  'Tìm bệnh viện',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 48), // Balancing back button
            ],
          ),

          const SizedBox(height: 8),

          // 2. Search Bar - Full Width
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
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
                hintText: 'Tìm kiếm...',
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
