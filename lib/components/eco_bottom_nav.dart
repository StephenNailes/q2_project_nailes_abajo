import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EcoBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const EcoBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Color(0xFF2ECC71); // Eco green
    const Color inactiveColor = Colors.grey;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          )
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 30, // Reduced from 70
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
                icon: Icons.lightbulb_outline,
                label: "Tips",
                index: 1,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              const SizedBox(width: 60), // space for floating action button
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
            context.go('/tips');
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
          Icon(icon, color: isActive ? activeColor : inactiveColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? activeColor : inactiveColor,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: activeColor,
                shape: BoxShape.circle,
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
    return SizedBox(
      width: 70,
      height: 70,
      child: FloatingActionButton(
        backgroundColor: const Color(0xFF2ECC71),
        elevation: 6,
        onPressed: () => context.go('/submissions'),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }
}
