import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      backgroundColor: const Color(0xFFFDF7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header đồng bộ chuẩn khoảng cách với Tra cứu thuốc
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Chi tiết thuốc',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Cân bằng kích thước với nút back (48px)
                ],
              ),
              const SizedBox(height: 16),

              // 1. Khung ảnh thuốc
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
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.medication, size: 90, color: Colors.grey),
                      )
                          : const Icon(Icons.medication, size: 90, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Badge Loại thuốc & Giá
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E2E2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'LOẠI THUỐC: $category',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Giá tiền
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/png/ic_tien.png',
                          width: 22,
                          height: 22,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          priceText,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB71C1C),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Khung thông tin xổ xuống (Accordion)
              _buildExpandableCard('Mô tả', mainEffect, defaultExpanded: true),
              _buildExpandableCard('Liều dùng, cách dùng', usage),
              _buildExpandableCard('Chống chỉ định', contraindications),
              _buildExpandableCard('Lưu ý', notes),

              const SizedBox(height: 24),

              // 4. Sản phẩm cùng loại (Động từ Supabase)
              const Text(
                'SẢN PHẨM CÙNG LOẠI',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              const SizedBox(height: 12),

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
                                  errorBuilder: (_, __, ___) => const Icon(Icons.medication, color: Color(0xFFE5B8B7), size: 36),
                                )
                                    : const Icon(Icons.medication, color: Color(0xFFE5B8B7), size: 36),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['name'] ?? '',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                maxLines: 1,
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
              const SizedBox(height: 20),
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
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                content,
                style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}