import 'package:flutter/material.dart';
import 'eco_tip_card.dart';

class EcoBookmarkedList extends StatefulWidget {
  final String searchQuery;
  const EcoBookmarkedList({super.key, required this.searchQuery});

  @override
  State<EcoBookmarkedList> createState() => _EcoBookmarkedListState();
}

class _EcoBookmarkedListState extends State<EcoBookmarkedList> {
  final List<Map<String, String>> _tips = [
    {
      "title": "Start composting kitchen scraps",
      "subtitle": "Reduces landfill waste and creates nutrient-rich soil",
    },
    {
      "title": "Switch to LED bulbs for 75% energy savings",
      "subtitle": "LED bulbs last 25 times longer than incandescent bulbs",
    },
    {
      "title": "Take shorter showers to conserve water",
      "subtitle": "A 5-minute shower uses about 25 gallons of water",
    },
  ];

  final List<bool> _bookmarked = List<bool>.filled(3, true);

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
