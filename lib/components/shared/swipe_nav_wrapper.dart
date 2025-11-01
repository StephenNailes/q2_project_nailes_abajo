import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Wrap a screen to support left/right swipe navigation between
/// Home (0), Community (1), Guides (2), Submissions (3), Profile (4)
class SwipeNavWrapper extends StatelessWidget {
  final int currentIndex;
  final Widget child;

  const SwipeNavWrapper({super.key, required this.currentIndex, required this.child});

  // Swipe order: Home (0), Community (1), Submissions (2), Guides (3), Profile (4)
  static const _routes = ['/home', '/community', '/submissions', '/guides', '/profile'];

  void _goTo(BuildContext context, int index) {
    if (index < 0 || index >= _routes.length) return;
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    // Use a GestureDetector around the whole screen
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity.abs() < 300) return; // ignore slow drags
        if (velocity < 0) {
          // Swipe left → next
          _goTo(context, currentIndex + 1);
        } else {
          // Swipe right → previous
          _goTo(context, currentIndex - 1);
        }
      },
      child: child,
    );
  }
}
