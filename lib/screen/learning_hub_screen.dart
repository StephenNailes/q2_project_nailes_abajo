import 'package:flutter/material.dart';
import '../components/eco_bottom_nav.dart';
import '../components/learninghub/hub_search_bar.dart';
import '../components/learninghub/tab_switcher.dart';
import '../components/learninghub/featured_banner.dart';
import '../components/learninghub/article_card.dart';
import '../components/learninghub/guide_card.dart';

class LearningHubScreen extends StatefulWidget {
  const LearningHubScreen({super.key});

  @override
  State<LearningHubScreen> createState() => _LearningHubScreenState();
}

class _LearningHubScreenState extends State<LearningHubScreen> {
  int _selectedTab = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
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
              Text("Learning Hub",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      )),
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
              HubSearchBar(
                controller: _searchController,
                onClear: _clearSearch,
              ),
              const SizedBox(height: 16),
              TabSwitcher(
                selectedTab: _selectedTab,
                onTabSelected: (index) =>
                    setState(() => _selectedTab = index),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: IndexedStack(
                  index: _selectedTab,
                  children: [
                    _buildFeaturedTab(),
                    _buildGuidesTab(),
                    _buildSavedTab(),
                  ],
                ),
              )
            ],
          ),
        ),
        floatingActionButton: const SubmissionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: const EcoBottomNavBar(currentIndex: 2),
      ),
    );
  }

  // -------- Tabs ----------

  Widget _buildFeaturedTab() {
    return _ArticleCardList(searchQuery: _searchQuery);
  }

  Widget _buildGuidesTab() {
    final guides = [
      GuideCard(
        title: "Complete Guide to Solar Energy for Your Home",
        subtitle: "Learn how to calculate your energy needs and choose the right solar setup",
        searchQuery: _searchQuery,
      ),
      GuideCard(
        title: "Understanding Your Carbon Footprint",
        subtitle: "Calculate, track, and reduce your environmental impact effectively",
        isBookmarked: true,
        searchQuery: _searchQuery,
      ),
      GuideCard(
        title: "Extend your device lifespan",
        subtitle: "Tips for maintaining your gadgets to reduce waste and save money",
        isBookmarked: true,
        searchQuery: _searchQuery,
      ),
      GuideCard(
        title: "Recycling electronics responsibly",
        subtitle: "Find out where and how to properly dispose of your old tech",
        searchQuery: _searchQuery,
      ),
    ];

    final filteredGuides = guides.where((g) {
      final title = g.title.toLowerCase();
      final subtitle = g.subtitle.toLowerCase();
      return title.contains(_searchQuery) || subtitle.contains(_searchQuery);
    }).toList();

    return ListView(children: filteredGuides);
  }

  Widget _buildSavedTab() {
    final saved = [
      GuideCard(
        title: "Smart Home Energy Monitoring Setup",
        subtitle: "Track and optimize your home's energy consumption with smart devices",
        isBookmarked: true,
        searchQuery: _searchQuery,
      ),
    ];

    final filteredSaved = saved.where((g) {
      final title = g.title.toLowerCase();
      final subtitle = g.subtitle.toLowerCase();
      return title.contains(_searchQuery) || subtitle.contains(_searchQuery);
    }).toList();

    return ListView(children: filteredSaved);
  }
}

// Add this widget at the end of the file to manage ArticleCard bookmarks.
class _ArticleCardList extends StatefulWidget {
  final String searchQuery;
  const _ArticleCardList({this.searchQuery = ''});

  @override
  State<_ArticleCardList> createState() => _ArticleCardListState();
}

class _ArticleCardListState extends State<_ArticleCardList> {
  final List<bool> _bookmarked = [false, false];

  @override
  Widget build(BuildContext context) {
    final articles = [
      {
        'title': "Smartphone Recycling Guide",
        'subtitle': "Step-by-step process to safely recycle your old phones",
        'time': "5 min read",
      },
      {
        'title': "Laptop Refurbishing Tips",
        'subtitle': "Transform old laptops into functional devices",
        'time': "8 min read",
      },
    ];

    final filteredArticles = articles.where((a) {
      final title = a['title']!.toLowerCase();
      final subtitle = a['subtitle']!.toLowerCase();
      final query = widget.searchQuery.toLowerCase();
      return title.contains(query) || subtitle.contains(query);
    }).toList();

    return ListView(
      children: [
        const FeaturedBanner(),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text("Trending This Week",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        ...List.generate(filteredArticles.length, (i) {
          final a = filteredArticles[i];
          // Find the original index to keep bookmarks in sync
          final originalIndex = articles.indexOf(a);
          return ArticleCard(
            title: a['title']!,
            subtitle: a['subtitle']!,
            time: a['time']!,
            isBookmarked: _bookmarked[originalIndex],
            searchQuery: widget.searchQuery,
            onBookmarkChanged: (val) {
              setState(() {
                _bookmarked[originalIndex] = val;
              });
            },
          );
        }),
      ],
    );
  }
}
