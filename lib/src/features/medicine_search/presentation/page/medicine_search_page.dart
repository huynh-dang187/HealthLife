import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../generated/assets.gen.dart';
import '../../../../common/constants/colors.dart';
import '../../../../shared/enums/bloc_status.dart';
import '../cubit/medicine_search_cubit.dart';
import '../widgets/category_card.dart';
import '../widgets/medicine_product_card.dart';
import 'medicine_detail_page.dart';

class MedicineSearchPage extends StatelessWidget {
  const MedicineSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MedicineSearchCubit(),
      child: const _MedicineSearchBody(),
    );
  }
}

class _MedicineSearchBody extends StatefulWidget {
  const _MedicineSearchBody();

  @override
  State<_MedicineSearchBody> createState() => _MedicineSearchBodyState();
}

class _MedicineSearchBodyState extends State<_MedicineSearchBody> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<MedicineSearchCubit>().fetchInitialMedicines();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<MedicineSearchCubit>().loadMoreMedicines();
    }
  }

  void _navigateToDetail(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicineDetailPage(medicine: item),
      ),
    );
  }

  void _triggerSearch(String query) {
    _searchController.text = query;
    context.read<MedicineSearchCubit>().searchMedicine(query);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        body: SafeArea(
          child: BlocBuilder<MedicineSearchCubit, MedicineSearchState>(
            builder: (context, state) {
              final isSearching = state.isSearching;
              final isLoading = state.status == BlocStatus.loading;

              return SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Assets.svg.icArrowLeft.svg(color: UIColors.black),
                          onPressed: () {
                            if (isSearching) {
                              _searchController.clear();
                              context.read<MedicineSearchCubit>().clearSearch();
                            } else {
                              Navigator.maybePop(context);
                            }
                          },
                        ),
                        Expanded(
                          child: Text(
                            'search_title'.tr(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xFFE5B8B7), width: 1.5),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (value) => _triggerSearch(value),
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'search_hint'.tr(),
                          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              context.read<MedicineSearchCubit>().clearSearch();
                            },
                          )
                              : Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Assets.png.icTimkiem.image(width: 20, height: 20, fit: BoxFit.contain),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (!isSearching) ...[
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.45,
                        children: [
                          CategoryCard(
                            title: 'pain_relief'.tr(),
                            iconAsset: Assets.png.icSot,
                            onTap: () => _triggerSearch('Giảm đau'),
                          ),
                          CategoryCard(
                            title: 'respiratory'.tr(),
                            iconAssets: [Assets.png.icCamcumhohap, Assets.png.icCamcumhohap2],
                            onTap: () => _triggerSearch('Hô hấp'),
                          ),
                          CategoryCard(
                            title: 'digestive'.tr(),
                            iconAssets: [Assets.png.icTieuhoa, Assets.png.icTieuhoa2],
                            onTap: () => _triggerSearch('Tiêu hóa'),
                          ),
                          CategoryCard(
                            title: 'dermatology'.tr(),
                            iconAssets: [Assets.png.icDalieu, Assets.png.icDalieu2],
                            onTap: () => _triggerSearch('Da liễu'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('popular_otc'.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (isSearching) ...[
                      Center(
                        child: Text(
                          '${'searching_for'.tr()} "${_searchController.text.trim()}"',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (state.relatedKeywords.isNotEmpty) ...[
                        Text('related_keywords'.tr(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: state.relatedKeywords.map((tag) {
                            return ActionChip(
                              label: Text(tag, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                              backgroundColor: const Color(0xFFEDEDED),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              onPressed: () => _triggerSearch(tag),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],

                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(color: Color(0xFFE5B8B7)),
                        ),
                      )
                    else if (state.medicines.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text('not_found'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 15)),
                        ),
                      )
                    else if (!isSearching)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.medicines.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                          itemBuilder: (context, index) {
                            final item = state.medicines[index];
                            return MedicineProductCard(
                              name: item['name'] ?? 'no_name'.tr(),
                              imageUrl: (item['image_url'] ?? '').toString().trim(),
                              isOtc: item['is_otc'] ?? true,
                              onTap: () => _navigateToDetail(item),
                            );
                          },
                        )
                      else ...[
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.medicines.length,
                            itemBuilder: (context, index) {
                              final item = state.medicines[index];
                              final String imageUrl = (item['image_url'] ?? '').toString().trim();
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _navigateToDetail(item),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFE5B8B7), width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 70, height: 70,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFDF0F0),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: imageUrl.isNotEmpty
                                            ? Image.network(imageUrl, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.medication, color: Colors.grey))
                                            : const Icon(Icons.medication, color: Colors.grey),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(item['name'] ?? 'no_name'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)),
                                            const SizedBox(height: 4),
                                            Text(
                                              item['usage_dosage'] ?? 'see_package_details'.tr(),
                                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                                              maxLines: 1, overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${'price'.tr()}: ${item['price_text'] ?? 'updating'.tr()}',
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          if (state.isLoadingMore)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(child: CircularProgressIndicator(color: Color(0xFFE5B8B7))),
                            ),
                        ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}