import 'package:flutter/material.dart';

class EcoTipCarousel extends StatefulWidget {
  final List<EcoTip> tips;

  const EcoTipCarousel({super.key, required this.tips});

  @override
  State<EcoTipCarousel> createState() => _EcoTipCarouselState();
}

class _EcoTipCarouselState extends State<EcoTipCarousel> {
  int _currentIndex = 0;

  void _refreshTip() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.tips.length;
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.eco, color: Color(0xFF2ECC71), size: 26),
                const SizedBox(width: 8),
                const Text(
                  "Daily EcoTips",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.black54),
                  onPressed: _refreshTip,
                  tooltip: "Refresh tip",
                ),
              ],
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 70,
                maxHeight: 120,
              ),
              child: PageView.builder(
                itemCount: widget.tips.length,
                controller: PageController(initialPage: _currentIndex),
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final ecoTip = widget.tips[index];
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE9FBEF), Color(0xFFD6F5E0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(ecoTip.icon, color: ecoTip.iconColor, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            ecoTip.tip,
                            style: const TextStyle(
                                color: Colors.black87, fontSize: 14),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.tips.length, (index) {
                return _buildDot(index == _currentIndex);
              }),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDot(bool active) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? Colors.black87 : Colors.grey,
      ),
    );
  }
}

class EcoTip {
  final String tip;
  final IconData icon;
  final Color iconColor;

  EcoTip({
    required this.tip,
    required this.icon,
    required this.iconColor,
  });
}
