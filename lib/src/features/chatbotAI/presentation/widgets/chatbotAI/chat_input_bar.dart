import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/core/presentation/widgets/text_field.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    this.onSend,
    this.enabled = true,
    required this.remaining,
    required this.total,
  });

  final ValueChanged<String>? onSend;
  final bool enabled;
  final int remaining;
  final int total;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled || widget.remaining <= 0) return;
    widget.onSend?.call(text);
    _controller.clear();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final ratio = widget.total <= 0
        ? 0.0
        : (widget.remaining / widget.total).clamp(0.0, 1.0);
    final isOut = widget.remaining <= 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isOut) ...[
          2.gap,
          AppText.regular(
            LocaleKeys.chatbot_chat_out_of_usage.tr(),
            fontSize: 12,
            color: const Color(0xFFC62828),
            textAlign: TextAlign.right,
          ),
          6.gap,
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                height: 46,
                child: AppTF.common(
                  controller: _controller,
                  hintText: LocaleKeys.chatbot_chat_input_hint,
                  height: 46,
                  borderCicular: 20,
                  textColor: UIColors.text,
                  onSubmitted: (_) => _submit(),
                ),
              ),
            ),
            4.gap,
            _SendButton(
              ratio: ratio,
              enabled: widget.enabled && !isOut,
              onTap: _submit,
            ),
          ],
        ),
      ],
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.ratio,
    required this.enabled,
    required this.onTap,
  });

  final double ratio;
  final bool enabled;
  final VoidCallback onTap;

  Color get _lineColor {
    if (ratio >= 0.6) return const Color(0xFF1FBF67);
    if (ratio >= 0.2) return const Color(0xFFF5A623);
    return const Color(0xFFE8434F);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: -1.5707963,
              child: CircularProgressIndicator(
                value: ratio,
                strokeWidth: 2,
                strokeCap: StrokeCap.round,
                backgroundColor: const Color(0xFFE3EFE8),
                valueColor: AlwaysStoppedAnimation(_lineColor),
              ),
            ),
            SizedBox(
              width: 34,
              height: 34,
              child: const Icon(
                Icons.send_rounded,
                size: 18,
                color: UIColors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UsageRemainingText extends StatelessWidget {
  const UsageRemainingText({
    super.key,
    required this.remaining,
    required this.total,
  });

  final int remaining;
  final int total;

  @override
  Widget build(BuildContext context) {
    return AppText.regular(
      LocaleKeys.chatbot_chat_usage_remaining.tr(
        namedArgs: {
          'remaining': '$remaining',
          'total': '$total',
        },
      ),
      fontSize: 12,
      color: UIColors.textBody,
    );
  }
}