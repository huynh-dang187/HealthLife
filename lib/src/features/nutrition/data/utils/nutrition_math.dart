/// Chuẩn hoá chuỗi tiếng Việt về dạng tìm kiếm không dấu, chữ thường.
///
/// Dữ liệu Firestore `foods.name_search` đã được lưu dạng này (VD: "pho bo"),
/// nên từ khoá người dùng nhập ("Phở Bò") phải được biến đổi giống hệt.
String normalizeVietnamese(String input) {
  const src =
      'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
  final dst = <String>[
    ...List.filled(17, 'a'),
    ...List.filled(11, 'e'),
    ...List.filled(5, 'i'),
    ...List.filled(17, 'o'),
    ...List.filled(11, 'u'),
    ...List.filled(5, 'y'),
    'd',
  ].join();

  assert(src.length == dst.length, 'Bảng chuyển đổi tiếng Việt bị lệch độ dài');

  final map = <String, String>{
    for (var i = 0; i < src.length; i++) src[i]: dst[i],
  };

  final lower = input.toLowerCase();
  final buffer = StringBuffer();
  for (var i = 0; i < lower.length; i++) {
    final ch = lower[i];
    buffer.write(map[ch] ?? ch);
  }

  return buffer
      .toString()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .join(' ');
}