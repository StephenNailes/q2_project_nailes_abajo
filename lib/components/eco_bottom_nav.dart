import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EcoBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const EcoBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Color(0xFF2ECC71); // Eco green
    const Color inactiveColor = Colors.black45;

    // Modern minimal BottomAppBar with true notch cutout (no outer container that blocks the notch)
    return BottomAppBar(
      color: Colors.white,
      elevation: 12,
      // Use the built-in circular notch and clip the shape so the FAB sits in a radial cutout
      shape: const CircularNotchedRectangle(),
      notchMargin: 6, // small, snug cutout around the FAB
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home_outlined,
                label: "Home",
                index: 0,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _buildNavItem(
                context,
                icon: Icons.people_outline,
                label: "Community",
                index: 1,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              const SizedBox(width: 64), // space beneath center FAB (matches FAB size)
              _buildNavItem(
                context,
                icon: Icons.menu_book_outlined,
                label: "Guides",
                index: 2,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _buildNavItem(
                context,
                icon: Icons.person_outline,
                label: "Profile",
                index: 4,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () {
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/community'); // Changed from /tips
            break;
          case 2:
            context.go('/guides');
            break;
          case 3:
            context.go('/submissions');
            break;
          case 4:
            context.go('/profile');
            break;
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22,
            color: isActive ? activeColor : inactiveColor,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? activeColor : inactiveColor,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// Floating submission button
class SubmissionButton extends StatelessWidget {
  const SubmissionButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Use standard 56-64 size so the BottomAppBar notch aligns neatly
    return SizedBox(
      width: 64,
      height: 64,
      child: FloatingActionButton(
        backgroundColor: const Color(0xFF2ECC71),
        elevation: 8,
        onPressed: () => context.go('/submissions'),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }
}
