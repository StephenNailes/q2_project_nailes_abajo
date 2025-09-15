import 'package:flutter/material.dart';

class GuideCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final bool isBookmarked;
  final ValueChanged<bool>? onBookmarkChanged;
  final String searchQuery;

  const GuideCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.isBookmarked = false,
    this.onBookmarkChanged,
    this.searchQuery = '',
  });

  @override
  State<GuideCard> createState() => _GuideCardState();
}

class _GuideCardState extends State<GuideCard> {
  late bool _bookmarked;

  @override
  void initState() {
    super.initState();
    _bookmarked = widget.isBookmarked;
  }

  void _toggleBookmark() {
    setState(() {
      _bookmarked = !_bookmarked;
    });
    if (widget.onBookmarkChanged != null) {
      widget.onBookmarkChanged!(_bookmarked);
    }
  }

  /// 🔍 Highlight search query inside text
  Widget _buildHighlightedText(
    String text,
    String query, {
    required TextStyle normalStyle,
    required TextStyle highlightStyle,
  }) {
    if (query.isEmpty || !text.toLowerCase().contains(query.toLowerCase())) {
      return Text(text, style: normalStyle);
    }

    final spans = <TextSpan>[];
    int start = 0;
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index < 0) {
        spans.add(TextSpan(
          text: text.substring(start),
          style: normalStyle,
        ));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: normalStyle,
        ));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: highlightStyle,
      ));

      start = index + query.length;
    }

    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE9FBEF),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(10),
            child:
                const Icon(Icons.article, color: Color(0xFF2ECC71), size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHighlightedText(
                  widget.title,
                  widget.searchQuery,
                  normalStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.black,
                  ),
                  highlightStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 6),
                _buildHighlightedText(
                  widget.subtitle,
                  widget.searchQuery,
                  normalStyle: const TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                  ),
                  highlightStyle: const TextStyle(
                    color: Colors.orange,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              _bookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _bookmarked ? const Color(0xFF2ECC71) : Colors.grey,
              size: 28,
            ),
            onPressed: _toggleBookmark,
            tooltip: _bookmarked ? 'Remove Bookmark' : 'Add Bookmark',
          ),
        ],
      ),
    );
  }
}
