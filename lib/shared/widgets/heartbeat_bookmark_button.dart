import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../models/item_model.dart';
import '../services/saved_items_service.dart';

class HeartbeatBookmarkButton extends StatefulWidget {
  final Item item;
  final VoidCallback? onToggled;
  final bool isCircleBg;

  const HeartbeatBookmarkButton({
    super.key,
    required this.item,
    this.onToggled,
    this.isCircleBg = false,
  });

  @override
  State<HeartbeatBookmarkButton> createState() => _HeartbeatBookmarkButtonState();
}

class _HeartbeatBookmarkButtonState extends State<HeartbeatBookmarkButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.4)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.reset();
    _controller.forward();
    SavedItemsService().toggleSave(widget.item);
    if (widget.onToggled != null) {
      widget.onToggled!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SavedItemsService(),
      builder: (context, _) {
        final isSaved = SavedItemsService().isSaved(widget.item.id);

        final icon = ScaleTransition(
          scale: _scaleAnimation,
          child: Icon(
            isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: isSaved ? context.colors.primaryTeal : (widget.isCircleBg ? context.colors.textLight : context.colors.textDark),
            size: widget.isCircleBg ? 20 : 24,
          ),
        );

        if (widget.isCircleBg) {
          return GestureDetector(
            onTap: _handleTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.colors.background,
                shape: BoxShape.circle,
              ),
              child: icon,
            ),
          );
        } else {
          return IconButton(
            icon: icon,
            onPressed: _handleTap,
          );
        }
      },
    );
  }
}
