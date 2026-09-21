import 'package:flutter/material.dart';

import 'src/features/count_steep/data/repositories/activity_repository.dart';

/// Trang test tạm thời cho ActivityRepository — KHÔNG nằm trong feature chính.
///
/// Mục đích: cầm điện thoại đi vài bước, xác nhận số bước (todaySteps)
/// tăng đúng qua cả Text lớn + log console trước khi ghép vào UI thật.
class ActivityRepositoryTestPage extends StatefulWidget {
  const ActivityRepositoryTestPage({super.key});

  @override
  State<ActivityRepositoryTestPage> createState() =>
      _ActivityRepositoryTestPageState();
}

class _ActivityRepositoryTestPageState extends State<ActivityRepositoryTestPage> {
  final ActivityRepository _repository = ActivityRepository();

  final List<String> _logs = [];
  bool? _permission;
  int _todaySteps = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _listen());
  }

  Future<void> _listen() async {
    _log('Đang xin quyền cảm biến...');
    final bool granted = await _repository.requestActivityPermission();
    _log('Kết quả quyền: $granted');
    if (!granted) {
      _writeError('Không có quyền → dừng. Vào Settings bật lại rồi thử.');
      return;
    }

    _repository.getSensorStepStream().listen(
      (today) {
        _log('sensor event -> todaySteps=$today');
        if (mounted) _setSteps(today);
      },
      onError: (Object e) {
        _log('Lỗi stream: $e');
        if (mounted) _writeError('$e');
      },
      onDone: () => _log('Stream kết thúc'),
    );
  }

  void _log(String line) {
    debugPrint('[ActivityTest] $line');
    if (mounted) {
      setState(() => _logs.insert(0, line));
    }
  }

  void _setSteps(int value) {
    setState(() => _todaySteps = value);
  }

  void _writeError(String message) {
    setState(() => _error = message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test ActivityRepository'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bước hôm nay',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              '$_todaySteps',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                _permission == null
                    ? 'đang xin quyền...'
                    : (_permission! ? 'đã có quyền ✅' : 'chưa có quyền ❌'),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'Bước này để người dùng đi vài bước và xác nhận số tăng đúng.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const Text(
              'Log console ([ActivityTest] / [ActivityRepo]):',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      _logs[index],
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}