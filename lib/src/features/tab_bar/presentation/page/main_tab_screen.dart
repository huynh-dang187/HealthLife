import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/generated/assets.gen.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/features/tab_bar/presentation/widget/app_glass.dart';
import 'package:healthlife/src/features/tab_bar/presentation/widget/tab_bar_item.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _TabInfo {
  const _TabInfo(this.icon, this.title);
  final Widget icon;
  final String title;
}

final _tabs = [
  _TabInfo(Assets.svg.icHome.svg(width: 25, height: 25), 'Trang chủ'),
  _TabInfo(Assets.svg.icNutrion.svg(width: 25, height: 25), 'Hoạt động'),
  _TabInfo(Assets.svg.icNutrion.svg(width: 25), 'Dinh dưỡng'),
  _TabInfo(Assets.svg.icExtension.svg(width: 25), 'Tiện ích'),
];

const _aiIndex = 4;

class _MainTabScreenState extends State<MainTabScreen>
    with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;
  late final AnimationController _aiController;
  late final Animation<double> _aiScale;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.95,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.95,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50.0,
      ),
    ]).animate(_scaleController);

    _aiController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _aiScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.9,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.9,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50.0,
      ),
    ]).animate(_aiController);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _aiController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    _scaleController.forward(from: 0.0);
    widget.navigationShell.goBranch(index);
  }

  void _onTapAi() {
    _aiController.forward(from: 0.0);
    widget.navigationShell.goBranch(_aiIndex);
  }

  GestureDetector buildAiButton(int index) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTapAi,
      child: ScaleTransition(
        scale: _aiScale,
        child: SizedBox(
          width: 80,
          height: 80,
          child: ClipOval(
            child: Assets.png.icChatbotAI.image(
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final index = widget.navigationShell.currentIndex;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (details) {
          final v = details.primaryVelocity ?? 0;
          if (v < -200 && index < _aiIndex) {
            _onTap(index + 1);
          } else if (v > 200 && index > 0) {
            _onTap(index - 1);
          }
        },
        child: widget.navigationShell,
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 16,
        ),
        child: SizedBox(
          height: 80,
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: SizedBox(
                                height: 55,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(32),
                                    boxShadow: [
                                      BoxShadow(
                                        color: UIColors.darkTextPrimary
                                            .withValues(
                                              alpha: 25,
                                            ),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: AppGlass(
                                    borderRadius: 32,
                                    border: Border.all(
                                      color: const Color.fromARGB(
                                        255,
                                        255,
                                        45,
                                        125,
                                      ).withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                    // ==== Preset "tấm gương" ====
                                    refraction: 80, // bóng/khúc xạ nhiều hơn
                                    depth: 20, // kính dày hơn → viền nổi rõ
                                    dispersion:
                                        12, // giảm viền cầu vồng để không loè
                                    frost:
                                        2, // blur mờ RẤT nhiều → nền chỉ còn màu loang như gương
                                    glassColor:
                                        const Color.fromARGB(
                                          255,
                                          255,
                                          45,
                                          125,
                                        ).withValues(
                                          alpha: 0.01,
                                        ),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      child: Row(
                                        children: [
                                          for (
                                            var i = 0;
                                            i < _tabs.length;
                                            i++
                                          ) ...[
                                            if (i > 0) 4.gap,
                                            Expanded(
                                              child: TabBarItem(
                                                icon: _tabs[i].icon,
                                                title: _tabs[i].title,
                                                selected: index == i,
                                                onTap: () => _onTap(i),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    2.gap,
                    buildAiButton(index),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
