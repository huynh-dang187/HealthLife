import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:healthlife/generated/locale_keys.g.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    this.onSend,
    this.enabled = true,
    this.remaining = 40,
    this.total = 50,
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
          const SizedBox(height: 4),
          AppText.regular(
            LocaleKeys.chatbot_chat_out_of_usage.tr(),
            fontSize: 12,
            color: const Color(0xFFC62828),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6FBF8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF1FBF67).withValues(alpha: 40),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  enabled: widget.enabled && !isOut,
                  minLines: 1,
                  maxLines: 4,
                  onSubmitted: (_) => _submit(),
                  style: const TextStyle(
                    color: UIColors.text,
                    fontSize: 14.5,
                  ),
                  decoration: InputDecoration(
                    hintText: LocaleKeys.chatbot_chat_input_hint.tr(),
                    hintStyle: const TextStyle(
                      color: UIColors.textBody,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            10.gap,
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
        width: 62,
        height: 62,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 62,
              height: 62,
              child: Transform.rotate(
                angle: -1.5707963,
                child: CircularProgressIndicator(
                  value: ratio,
                  strokeWidth: 4,
                  strokeCap: StrokeCap.round,
                  backgroundColor: const Color(0xFFE3EFE8),
                  valueColor: AlwaysStoppedAnimation(_lineColor),
                ),
              ),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: enabled
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF3EDC85), Color(0xFF1FBF67)],
                      )
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFB9C6C0), Color(0xFF93A39C)],
                      ),
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: const Color(0xFF1FBF67).withValues(alpha: 35),
                          blurRadius: 18,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: const Icon(
                Icons.send_rounded,
                size: 22,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}