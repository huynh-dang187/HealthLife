import 'package:flutter/material.dart';

import '../../../common/constants/colors.dart';

class AppDropdown extends StatefulWidget {
  final List<String> items;
  final String? selected;
  final ValueChanged<String> onChanged;
  final Widget btn;

  const AppDropdown({
    super.key,
    required this.items,
    this.selected,
    required this.onChanged,
    required this.btn,
  });

  @override
  State<AppDropdown> createState() => _AppDropdownState();
}

class _AppDropdownState extends State<AppDropdown> {
  OverlayEntry? _overlayEntry;

  bool get _isOpen => _overlayEntry != null;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggle() => _isOpen ? _removeOverlay() : _showOverlay();

  void _showOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _removeOverlay,
            ),
          ),
          Positioned(
            width: size.width,
            left: offset.dx,
            top: offset.dy + size.height + 8,
            child: Material(
              color: UIColors.white,
              borderRadius: BorderRadius.circular(20),
              clipBehavior: Clip.antiAlias,
              elevation: 6,
              shadowColor: Colors.black26,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  children: widget.items.map(_buildItem).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildItem(String item) {
    final isSelected = item == widget.selected;
    return GestureDetector(
      onTap: () {
        widget.onChanged(item);
        _removeOverlay();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isSelected ? UIColors.lightGray : Colors.transparent,
        child: Text(
          item,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: UIColors.text,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: _toggle, child: widget.btn);
  }
}
