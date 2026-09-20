import 'package:flutter/material.dart';
import 'package:healthlife/src/core/presentation/widgets/no_data.dart';

/// Nội dung tab "Lịch sử" — chưa có dữ liệu.
class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const NoData.list(title: 'Chưa có dữ liệu lịch sử');
  }
}