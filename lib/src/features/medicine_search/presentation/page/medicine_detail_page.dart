import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../generated/assets.gen.dart';
import '../../../../common/constants/colors.dart';
import '../../../../common/extensions/num_x.dart';
import '../../../../core/presentation/widgets/text.dart';

class MedicineDetailPage extends StatefulWidget {
  final Map<String, dynamic> medicine;

  const MedicineDetailPage({super.key, required this.medicine});

  @override
  State<MedicineDetailPage> createState() => _MedicineDetailPageState();
}

class _MedicineDetailPageState extends State<MedicineDetailPage> {
  List<Map<String, dynamic>> _relatedMedicines = [];
  bool _isLoadingRelated = false;

  @override
  void initState() {
    super.initState();
    _fetchRelatedMedicines();
  }

  // Tải danh sách thuốc cùng danh mục từ Supabase
  Future<void> _fetchRelatedMedicines() async {
    final category = widget.medicine['category'];
    final currentId = widget.medicine['id'];

    if (category == null) return;

    setState(() => _isLoadingRelated = true);
    try {
      final response = await Supabase.instance.client
          .from('medicines')
          .select()
          .eq('category', category)
          .filter('id', 'neq', currentId ?? -1)
          .limit(6);

      setState(() {
        _relatedMedicines = List<Map<String, dynamic>>.from(response);
        _isLoadingRelated = false;
      });
    } catch (e) {
      setState(() => _isLoadingRelated = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.medicine['name'] ?? 'Chưa có tên';
    final String imageUrl = (widget.medicine['image_url'] ?? '').toString().trim();
    final String category = widget.medicine['category'] ?? 'Chưa phân loại';
    final String priceText = widget.medicine['price_text'] ?? 'Đang cập nhật';

    final String mainEffect = widget.medicine['main_effect'] ?? 'Đang cập nhật thông tin tác dụng chính.';
    final String usage = widget.medicine['usage_instructions'] ?? 'Đang cập nhật hướng dẫn sử dụng.';
    final String contraindications = widget.medicine['contraindications'] ?? 'Đang cập nhật chống chỉ định.';
    final String notes = widget.medicine['notes'] ?? 'Đang cập nhật lưu ý khi dùng.';

    return Scaffold(
      backgroundColor: UIColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => context.pop(),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Assets.svg.icArrowLeft.svg(
                        colorFilter: const ColorFilter.mode(UIColors.black, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  Expanded(
                    child: AppText.bold(
                      'Chi tiết thuốc',
                      textAlign: TextAlign.center,
                      fontSize: 22,
                      color: Colors.black,
                    ),
                  ),
                  48.gap,
                ],
              ),
              16.gap,

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 170,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Assets.png.icSot.image(height: 90, fit: BoxFit.contain),
                        )
                            : Assets.png.icSot.image(height: 90, fit: BoxFit.contain),
                      ),
                    ),
                    12.gap,
                    Text(
                      name.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              16.gap,

              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E2E2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AppText.bold(
                        'LOẠI THUỐC: $category',
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                    8.gap,

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Assets.png.icTien.image(
                          width: 22,
                          height: 22,
                          fit: BoxFit.contain,
                        ),
                        6.gap,
                        AppText.bold(
                          priceText,
                          fontSize: 20,
                          color: const Color(0xFFB71C1C),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              20.gap,

              _buildExpandableCard('Mô tả', mainEffect, defaultExpanded: true),
              _buildExpandableCard('Liều dùng, cách dùng', usage),
              _buildExpandableCard('Chống chỉ định', contraindications),
              _buildExpandableCard('Lưu ý', notes),

              24.gap,

              AppText.bold(
                'SẢN PHẨM CÙNG LOẠI',
                fontSize: 15,
              ),
              12.gap,

              if (_isLoadingRelated)
                const Center(child: CircularProgressIndicator(color: Color(0xFFE5B8B7)))
              else if (_relatedMedicines.isEmpty)
                const Text('Không có sản phẩm cùng loại', style: TextStyle(color: Colors.grey, fontSize: 13))
              else
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _relatedMedicines.length,
                    itemBuilder: (context, index) {
                      final item = _relatedMedicines[index];
                      final String relImageUrl = (item['image_url'] ?? '').toString().trim();
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MedicineDetailPage(medicine: item),
                            ),
                          );
                        },
                        child: Container(
                          width: 110,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5B8B7)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: relImageUrl.isNotEmpty
                                    ? Image.network(
                                  relImageUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Assets.png.icSot.image(height: 36, fit: BoxFit.contain),
                                )
                                    : Assets.png.icSot.image(height: 36, fit: BoxFit.contain),
                              ),
                              6.gap,
                              Text(
                                item['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              20.gap,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableCard(String title, String content, {bool defaultExpanded = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5B8B7), width: 1.2),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        initiallyExpanded: defaultExpanded,
        title: AppText.bold(
          title,
          fontSize: 14,
          color: Colors.black87,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}