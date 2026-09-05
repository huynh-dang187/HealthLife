import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/category_card.dart';
import '../widgets/medicine_product_card.dart';
import 'medicine_detail_page.dart';

class MedicineSearchPage extends StatefulWidget {
  const MedicineSearchPage({super.key});

  @override
  State<MedicineSearchPage> createState() => _MedicineSearchPageState();
}

class _MedicineSearchPageState extends State<MedicineSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<String> _relatedKeywords = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchInitialMedicines();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialMedicines() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .rpc('get_random_otc_medicines', params: {'limit_count': 6});

      setState(() {
        _searchResults = List<Map<String, dynamic>>.from(response);
        _relatedKeywords = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchMedicine(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      _fetchInitialMedicines();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client
          .from('medicines')
          .select()
          .or('name.ilike.%$cleanQuery%,active_ingredient.ilike.%$cleanQuery%,category.ilike.%$cleanQuery%');

      final results = List<Map<String, dynamic>>.from(response);

      final Set<String> extractedKeywords = {};
      for (var item in results) {
        final ingredient = item['active_ingredient']?.toString().trim();
        final category = item['category']?.toString().trim();

        if (ingredient != null &&
            ingredient.isNotEmpty &&
            !ingredient.toLowerCase().contains(cleanQuery.toLowerCase())) {
          extractedKeywords.add(ingredient);
        }

        if (category != null &&
            category.isNotEmpty &&
            !category.toLowerCase().contains(cleanQuery.toLowerCase())) {
          extractedKeywords.add(category);
        }
      }

      setState(() {
        _searchResults = results;
        _relatedKeywords = extractedKeywords.take(4).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    final bool isSearching = _searchController.text.trim().isNotEmpty;

    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        colorScheme: const ColorScheme.light(
          surface: Color(0xFFF7F7F7),
          onSurface: Colors.black,
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                      onPressed: () {
                        if (isSearching) {
                          _searchController.clear();
                          _fetchInitialMedicines();
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

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFFE5B8B7), width: 1.5),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => _searchMedicine(value),
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
                          _fetchInitialMedicines();
                        },
                      )
                          : Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset(
                          'assets/png/ic_timkiem.png',
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Danh mục ban đầu
                if (!isSearching) ...[
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      CategoryCard(
                        title: 'pain_relief'.tr(),
                        imagePath: 'assets/png/ic_sot.png',
                        onTap: () {
                          _searchController.text = 'Giảm đau';
                          _searchMedicine('Giảm đau');
                        },
                      ),
                      CategoryCard(
                        title: 'respiratory'.tr(),
                        imagePaths: const [
                          'assets/png/ic_camcumhohap.png',
                          'assets/png/ic_camcumhohap (2).png',
                        ],
                        onTap: () {
                          _searchController.text = 'Hô hấp';
                          _searchMedicine('Hô hấp');
                        },
                      ),
                      CategoryCard(
                        title: 'digestive'.tr(),
                        imagePaths: const [
                          'assets/png/ic_tieuhoa.png',
                          'assets/png/ic_tieuhoa (2).png',
                        ],
                        onTap: () {
                          _searchController.text = 'Tiêu hóa';
                          _searchMedicine('Tiêu hóa');
                        },
                      ),
                      CategoryCard(
                        title: 'dermatology'.tr(),
                        imagePaths: const [
                          'assets/png/ic_dalieu.png',
                          'assets/png/ic_dalieu (2).png',
                        ],
                        onTap: () {
                          _searchController.text = 'Da liễu';
                          _searchMedicine('Da liễu');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'popular_otc'.tr(),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.grey),
                        onPressed: _fetchInitialMedicines,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Giao diện khi tìm kiếm
                if (isSearching) ...[
                  Center(
                    child: Text(
                      '${'searching_for'.tr()} "${_searchController.text.trim()}"',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_relatedKeywords.isNotEmpty) ...[
                    Text('related_keywords'.tr(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _relatedKeywords.map((tag) {
                        return ActionChip(
                          label: Text(tag, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                          backgroundColor: const Color(0xFFEDEDED),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          onPressed: () {
                            _searchController.text = tag;
                            _searchMedicine(tag);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],

                // Danh sách sản phẩm
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(color: Color(0xFFE5B8B7)),
                    ),
                  )
                else if (_searchResults.isEmpty)
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
                      itemCount: _searchResults.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (context, index) {
                        final item = _searchResults[index];
                        return MedicineProductCard(
                          name: item['name'] ?? 'no_name'.tr(),
                          imageUrl: (item['image_url'] ?? '').toString().trim(),
                          isOtc: item['is_otc'] ?? true,
                          onTap: () => _navigateToDetail(item),
                        );
                      },
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final item = _searchResults[index];
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
                                  width: 70,
                                  height: 70,
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
                                      Text(
                                        item['name'] ?? 'no_name'.tr(),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['usage_dosage'] ?? 'see_package_details'.tr(),
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}