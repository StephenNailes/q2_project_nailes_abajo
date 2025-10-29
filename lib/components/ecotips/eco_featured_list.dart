import 'package:flutter/material.dart';
import 'eco_tip_card.dart';

class EcoFeaturedList extends StatefulWidget {
  final String searchQuery;
  const EcoFeaturedList({super.key, required this.searchQuery});

  @override
  State<EcoFeaturedList> createState() => _EcoFeaturedListState();
}

class _EcoFeaturedListState extends State<EcoFeaturedList> {
  final List<Map<String, String>> _tips = [
    {
      "title": "Find local e-waste recycling centers",
      "subtitle": "Drop off old electronics at certified facilities.",
    },
    {
      "title": "Repair devices instead of replacing",
      "subtitle": "Extend the life of your electronics and reduce waste.",
    },
    {
      "title": "Donate or recycle old tablets and laptops",
      "subtitle": "Keep hazardous materials out of landfills by recycling responsibly.",
    },
    {
      "title": "Safely dispose of old batteries",
      "subtitle": "Use battery recycling bins to prevent soil and water contamination.",
    },
    {
      "title": "Sell or give away unused electronics",
      "subtitle": "Extend device life and reduce e-waste by passing them on.",
    },
    {
      "title": "Choose devices with longer lifespans",
      "subtitle": "Buy quality electronics that last and are repairable.",
    },
  ];

  final List<bool> _bookmarked = List<bool>.filled(6, false);

  @override
  Widget build(BuildContext context) {
    final query = widget.searchQuery.toLowerCase();
    final filteredTips = _tips
        .asMap()
        .entries
        .where((entry) =>
            entry.value["title"]!.toLowerCase().contains(query) ||
            entry.value["subtitle"]!.toLowerCase().contains(query))
        .toList();

    return ListView(
      children: [
        if (query.isEmpty)
          // Featured tip (no bookmark)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: AssetImage("lib/assets/images/ewaste.png"),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.black.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Featured pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Featured",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Title
                      const Text(
                        "Donate or recycle old phones instead of throwing them away",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Subtitle
                      const Text(
                        "Proper e-waste recycling prevents toxic waste in landfills",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ...filteredTips.map((entry) {
          final idx = entry.key;
          final tip = entry.value;
          return EcoTipCard(
            title: tip["title"]!,
            subtitle: tip["subtitle"]!,
            bookmarked: _bookmarked[idx],
            onBookmark: () {
              setState(() {
                _bookmarked[idx] = !_bookmarked[idx];
              });
            },
            searchQuery: widget.searchQuery, // 🔍 pass query for highlighting
          );
        }),
        if (filteredTips.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text("No tips found.", style: TextStyle(fontSize: 16)),
            ),
          ),
      ],
    );
  }
}
