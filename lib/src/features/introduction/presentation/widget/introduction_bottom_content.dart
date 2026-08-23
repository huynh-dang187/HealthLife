import 'package:flutter/material.dart';
import 'package:healthlife/src/common/extensions/context_x.dart';
import 'package:healthlife/src/features/introduction/data/introduction_page_model.dart';

class IntroductionPageItem extends StatelessWidget {
  final IntroductionPageModel data;

  const IntroductionPageItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        data.backgroundImage.image(fit: BoxFit.cover),
        // Container(
        //   decoration: const BoxDecoration(
        //     gradient: LinearGradient(
        //       begin: Alignment.topCenter,
        //       end: Alignment.bottomCenter,
        //       colors: [Colors.transparent, Colors.transparent],
        //     ),
        //   ),
        // ),
        // if (data.floatingCards != null)
        //   ...data.floatingCards!.map(
        //     (card) => Positioned(
        //       top: card.top,
        //       right: card.right,
        //       child: _FloatingCard(data: card),
        //     ),
        //   ),
      ],
    );
  }
}

class _FloatingCard extends StatelessWidget {
  final FloatingCardModel data;

  const _FloatingCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.paddingBottomForButton),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(data.icon, width: 20, height: 20),
            if (data.label != null) ...[
              const SizedBox(width: 6),
              Text(
                data.label!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
