import 'package:flutter/material.dart';

class TabSwitcher extends StatelessWidget {
  final int selectedTab;
  final Function(int) onTabSelected;

  const TabSwitcher({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  Widget _buildTab(String label, int index) {
    final bool isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2ECC71) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildTab("Featured", 0),
        const SizedBox(width: 12),
        _buildTab("Guides", 1),
        const SizedBox(width: 12),
        _buildTab("Saved", 2),
      ],
    );
  }
}
