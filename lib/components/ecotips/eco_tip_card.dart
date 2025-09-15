import 'package:flutter/material.dart';

class EcoTipCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool bookmarked;
  final VoidCallback? onBookmark;
  final String searchQuery;

  const EcoTipCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.bookmarked = false,
    this.onBookmark,
    this.searchQuery = '',
  });

  // 🔹 Helper function to highlight search query
  Widget _highlightText(String text, String query, BuildContext context) {
    if (query.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          fontSize: text == title ? 18 : 15,
          fontWeight: text == title ? FontWeight.bold : FontWeight.normal,
          color: text == title ? const Color(0xFF2ECC71) : Colors.black87,
        ),
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    final startIndex = lowerText.indexOf(lowerQuery);
    if (startIndex == -1) {
      return Text(
        text,
        style: TextStyle(
          fontSize: text == title ? 18 : 15,
          fontWeight: text == title ? FontWeight.bold : FontWeight.normal,
          color: text == title ? const Color(0xFF2ECC71) : Colors.black87,
        ),
      );
    }

    final endIndex = startIndex + query.length;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text.substring(0, startIndex),
            style: TextStyle(
              fontSize: text == title ? 18 : 15,
              fontWeight: text == title ? FontWeight.bold : FontWeight.normal,
              color: text == title ? const Color(0xFF2ECC71) : Colors.black87,
            ),
          ),
          TextSpan(
            text: text.substring(startIndex, endIndex),
            style: TextStyle(
              fontSize: text == title ? 18 : 15,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor, // highlight
            ),
          ),
          TextSpan(
            text: text.substring(endIndex),
            style: TextStyle(
              fontSize: text == title ? 18 : 15,
              fontWeight: text == title ? FontWeight.bold : FontWeight.normal,
              color: text == title ? const Color(0xFF2ECC71) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _highlightText(title, searchQuery, context),
                  const SizedBox(height: 8),
                  _highlightText(subtitle, searchQuery, context),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                bookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: bookmarked ? Colors.orangeAccent : Colors.grey,
                size: 28,
              ),
              onPressed: onBookmark,
            ),
          ],
        ),
      ),
    );
  }
}
