import 'package:flutter/material.dart';
import '../components/eco_bottom_nav.dart';
import '../components/ecotips/eco_search_bar.dart';
import '../components/ecotips/eco_tab_switcher.dart';
import '../components/ecotips/eco_featured_list.dart';
import '../components/ecotips/eco_bookmarked_list.dart';


class EcoTipsScreen extends StatefulWidget {
  const EcoTipsScreen({super.key});

  @override
  State<EcoTipsScreen> createState() => _EcoTipsScreenState();
}

class _EcoTipsScreenState extends State<EcoTipsScreen> {
  bool isFeatured = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
  setState(() {
    _searchQuery = _searchController.text.trim().toLowerCase();
  });
}

  void _clearSearch() {
  _searchController.clear();
  setState(() {
    _searchQuery = '';
  });
}

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE9FBEF), Color(0xFFD6F5E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Image.asset('lib/assets/images/logo.png', height: 32),
              const SizedBox(width: 8),
              Text(
                "Eco Tips",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
            ],
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.settings, color: Colors.black54),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              EcoSearchBar(
                controller: _searchController,
                onClear: _clearSearch,
              ),
              const SizedBox(height: 16),

              EcoTabSwitcher(
                isFeatured: isFeatured,
                onTabChanged: (value) => setState(() => isFeatured = value),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: isFeatured
                    ? EcoFeaturedList(searchQuery: _searchQuery)
                    : EcoBookmarkedList(searchQuery: _searchQuery),
              ),
            ],
          ),
        ),
        floatingActionButton: const SubmissionButton(), // Add this line
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Optional: match dashboard
        bottomNavigationBar: const EcoBottomNavBar(currentIndex: 1),
      ),
    );
  }
}
