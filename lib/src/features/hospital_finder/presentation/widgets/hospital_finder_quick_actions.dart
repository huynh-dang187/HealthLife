import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/hospital_finder_cubit.dart';
import '../cubit/hospital_finder_state.dart';

class HospitalFinderQuickActions extends StatelessWidget {
  const HospitalFinderQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HospitalFinderCubit, HospitalFinderState>(
      buildWhen: (previous, current) =>
      previous.isQuickMenuOpen != current.isQuickMenuOpen,
      builder: (context, state) {
        final isOpen = state.isQuickMenuOpen;

        return Stack(
          children: [
            // 1. Lớp phủ mờ nền khi mở menu Quick Action
            if (isOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => context.read<HospitalFinderCubit>().toggleQuickMenu(),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                ),
              ),

            // 2. Cụm nút Quick Action (Đặt ở khoảng 35% màn hình tính từ trên xuống)
            Positioned(
              right: 16,
              top: MediaQuery.of(context).size.height * 0.35,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: isOpen
                    ? _buildExpandedMenu(context)
                    : _buildCollapsedButton(context),
              ),
            ),
          ],
        );
      },
    );
  }

  // Nút Sấm Sét tròn khi đang đóng (Thêm padding top 90 để đứng yên đúng vị trí khi mở menu)
  Widget _buildCollapsedButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 90),
      child: FloatingActionButton(
        heroTag: 'quick_action_toggle',
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        elevation: 4,
        onPressed: () => context.read<HospitalFinderCubit>().toggleQuickMenu(),
        child: const Icon(Icons.flash_on, color: Colors.orange, size: 28),
      ),
    );
  }

  // Giao diện khi menu mở tỏa ra
  Widget _buildExpandedMenu(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 260,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerRight,
        children: [
          // Nút Sấm Sét ở trung tâm bên phải (Hình tròn)
          Positioned(
            right: 0,
            top: 90,
            child: FloatingActionButton(
              heroTag: 'quick_action_main',
              backgroundColor: Colors.white,
              shape: const CircleBorder(),
              elevation: 4,
              onPressed: () => context.read<HospitalFinderCubit>().toggleQuickMenu(),
              child: const Icon(Icons.flash_on, color: Colors.orange, size: 28),
            ),
          ),

          // 1. Nút "Địa chỉ đã thêm trước đó" (Phía TRÊN)
          Positioned(
            right: 0,
            top: 10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLabel('Địa chỉ đã thêm trước đó'),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.location_on,
                  iconColor: Colors.pinkAccent,
                  onTap: () {
                    // TODO: Thao tác mở danh sách địa chỉ đã thêm
                  },
                ),
              ],
            ),
          ),

          // 2. Nút "Đường đến bệnh viện gần nhất" (Bên TRÁI nút Sấm Sét)
          Positioned(
            right: 68,
            top: 90,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLabel('Đường đến bệnh viện gần nhất'),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.local_hospital,
                  iconColor: Colors.blueAccent,
                  onTap: () {
                    // TODO: Dẫn đường bệnh viện gần nhất
                  },
                ),
              ],
            ),
          ),

          // 3. Nút "Trở lại" / Đóng (Phía DƯỚI nút Sấm Sét)
          Positioned(
            right: 0,
            top: 170,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => context.read<HospitalFinderCubit>().toggleQuickMenu(),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 30),
                  ),
                ),
                const SizedBox(height: 6),
                _buildLabel('Trở lại'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 26),
      ),
    );
  }

  // Thẻ chứa nhãn chữ có nền trắng bo góc giúp dễ đọc trên bản đồ
  Widget _buildLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
