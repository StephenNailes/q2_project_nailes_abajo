import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import 'login_screen.dart';
import 'videos/videos_list_screen.dart';
import 'articles/articles_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  final _service = AdminSupabaseService();
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Screens (removed Analytics from list)
  final List<Widget> _screens = [
    const DashboardHomeScreen(),
    const VideosListScreen(),
    const ArticlesListScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onNavItemTap(int index) {
    if (_selectedIndex != index) {
      _animationController.reset();
      setState(() {
        _selectedIndex = index;
      });
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: Color(0xFF2ECC71),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EcoSustain',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Admin Panel',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const Divider(height: 1),
                
                // Menu items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildNavItem(0, Icons.dashboard, 'Dashboard'),
                      _buildNavItem(1, Icons.video_library, 'Videos'),
                      _buildNavItem(2, Icons.article, 'Articles'),
                    ],
                  ),
                ),
                
                const Divider(height: 1),
                
                // Logout button
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Sign Out'),
                  onTap: () async {
                    // Sign out from Supabase
                    await _service.signOut();
                    
                    // Use addPostFrameCallback to avoid navigator lock
                    if (!mounted) return;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Main content with fade animation
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF2ECC71).withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF2ECC71) : Colors.black54,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF2ECC71) : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          _onNavItemTap(index);
        },
      ),
    );
  }
}

// Placeholder Dashboard Home Screen
class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  final _service = AdminSupabaseService();

  bool _isLoading = true;
  // Date range filter
  String _range = '7d'; // '7d' | '30d' | '90d'
  int _totalVideos = 0;
  int _totalArticles = 0;
  int _totalVideoViews = 0;
  int _totalArticleViews = 0;
  int? _deltaVideoViews; // positive/negative vs previous period
  int? _deltaArticleViews;
  int? _deltaVideos; // new items vs previous period
  int? _deltaArticles;
  List<Map<String, dynamic>> _topVideos = [];
  List<Map<String, dynamic>> _topArticles = [];
  Map<String, int> _videoCategoryDistribution = {};
  Map<String, int> _articleCategoryDistribution = {};

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _service.getVideos(),
        _service.getArticles(),
      ]);

      final videos = results[0];
      final articles = results[1];

      // Totals (all time)
      _totalVideos = videos.length;
      _totalArticles = articles.length;
      // Some schemas use "views" while others expose a computed "views_count"
    int readViews(Map<String, dynamic> m) =>
          (m['views'] as int?) ?? (m['views_count'] as int?) ?? 0;
    _totalVideoViews = videos.fold<int>(0, (sum, v) => sum + readViews(v));
    _totalArticleViews = articles.fold<int>(0, (sum, a) => sum + readViews(a));

      // --- Range-based metrics (requires per-item created_at or separate views tables) ---
      final now = DateTime.now();
      final start = _range == '7d'
          ? now.subtract(const Duration(days: 7))
          : _range == '30d'
              ? now.subtract(const Duration(days: 30))
              : now.subtract(const Duration(days: 90));
      final prevStart = _range == '7d'
          ? now.subtract(const Duration(days: 14))
          : _range == '30d'
              ? now.subtract(const Duration(days: 60))
              : now.subtract(const Duration(days: 180));
      final prevEnd = start;

      // New items delta (based on created_at)
      int inRange(Iterable<Map<String, dynamic>> list, DateTime a, DateTime b) {
        int c = 0;
        for (final m in list) {
          final createdAtStr = m['created_at']?.toString();
          if (createdAtStr == null) continue;
          try {
            final created = DateTime.parse(createdAtStr);
            if (created.isAfter(a) && created.isBefore(b)) c++;
          } catch (_) {}
        }
        return c;
      }
      final currNewVideos = inRange(videos, start, now);
      final currNewArticles = inRange(articles, start, now);
      final prevNewVideos = inRange(videos, prevStart, prevEnd);
      final prevNewArticles = inRange(articles, prevStart, prevEnd);
      _deltaVideos = currNewVideos - prevNewVideos;
      _deltaArticles = currNewArticles - prevNewArticles;

      // Views delta: try querying optional event tables, fallback to null
      try {
        final vidsCurr = await Supabase.instance.client
            .from('video_views')
            .select('id, created_at')
            .gte('created_at', start.toIso8601String())
            .lte('created_at', now.toIso8601String());
        final vidsPrev = await Supabase.instance.client
            .from('video_views')
            .select('id, created_at')
            .gte('created_at', prevStart.toIso8601String())
            .lte('created_at', prevEnd.toIso8601String());
        final artsCurr = await Supabase.instance.client
            .from('article_views')
            .select('id, created_at')
            .gte('created_at', start.toIso8601String())
            .lte('created_at', now.toIso8601String());
        final artsPrev = await Supabase.instance.client
            .from('article_views')
            .select('id, created_at')
            .gte('created_at', prevStart.toIso8601String())
            .lte('created_at', prevEnd.toIso8601String());
        _deltaVideoViews = (vidsCurr as List).length - (vidsPrev as List).length;
        _deltaArticleViews = (artsCurr as List).length - (artsPrev as List).length;
      } catch (_) {
        // Optional tables may not exist yet; hide deltas gracefully
        _deltaVideoViews = null;
        _deltaArticleViews = null;
      }

      // Top content (by views)
      final sortedVideos = List<Map<String, dynamic>>.from(videos)
        ..sort((a, b) => (b['views_count'] as int? ?? 0).compareTo(a['views_count'] as int? ?? 0));
      _topVideos = sortedVideos.take(5).toList();

      final sortedArticles = List<Map<String, dynamic>>.from(articles)
        ..sort((a, b) => (b['views_count'] as int? ?? 0).compareTo(a['views_count'] as int? ?? 0));
      _topArticles = sortedArticles.take(5).toList();

      // Category distribution
      _videoCategoryDistribution = {};
      for (final v in videos) {
        final category = v['category']?.toString() ?? 'Uncategorized';
        _videoCategoryDistribution[category] = (_videoCategoryDistribution[category] ?? 0) + 1;
      }

      _articleCategoryDistribution = {};
      for (final a in articles) {
        final category = a['category']?.toString() ?? 'Uncategorized';
        _articleCategoryDistribution[category] = (_articleCategoryDistribution[category] ?? 0) + 1;
      }

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load analytics: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F7FA),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Tooltip(
                message: 'Refresh analytics',
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2ECC71)),
                  onPressed: _loadAnalytics,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text('Refresh', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // KPIs with trend deltas
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Videos', _totalVideos.toString(), Icons.video_library, const Color(0xFF3498DB), delta: _deltaVideos)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Total Articles', _totalArticles.toString(), Icons.article, const Color(0xFF9B59B6), delta: _deltaArticles)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Video Views', _totalVideoViews.toString(), Icons.visibility, const Color(0xFFE74C3C), delta: _deltaVideoViews)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Article Views', _totalArticleViews.toString(), Icons.remove_red_eye, const Color(0xFFF39C12), delta: _deltaArticleViews)),
            ],
          ),

          const SizedBox(height: 24),

          // Range selector
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: '7d', label: Text('Last 7d')),
                ButtonSegment(value: '30d', label: Text('Last 30d')),
                ButtonSegment(value: '90d', label: Text('Last 90d')),
              ],
              selected: {_range},
              onSelectionChanged: (s) {
                setState(() => _range = s.first);
                _loadAnalytics();
              },
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2ECC71)),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        // Charts
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildCategoryChart(
                                'Video Categories',
                                _videoCategoryDistribution,
                                const Color(0xFF3498DB),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildCategoryChart(
                                'Article Categories',
                                _articleCategoryDistribution,
                                const Color(0xFF9B59B6),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Top content
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTopContentCard(
                                'Top 5 Videos',
                                _topVideos,
                                Icons.video_library,
                                const Color(0xFF3498DB),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTopContentCard(
                                'Top 5 Articles',
                                _topArticles,
                                Icons.article,
                                const Color(0xFF9B59B6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ============ UI Helpers ============
  Widget _buildStatCard(String title, String value, IconData icon, Color color, {int? delta}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Colors.white.withValues(alpha: 0.9)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              if (delta != null)
                _buildDeltaPill(delta),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeltaPill(int delta) {
    final isUp = delta >= 0;
    final bg = (isUp ? Colors.green : Colors.red).withValues(alpha: 0.12);
    final fg = isUp ? const Color(0xFF1E8E3E) : const Color(0xFFB00020);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isUp ? Icons.north_east : Icons.south_east, size: 12, color: fg),
          const SizedBox(width: 4),
          Text('${isUp ? '+' : ''}$delta', style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(String title, Map<String, int> data, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: data.isEmpty
                ? Center(child: Text('No data', style: TextStyle(color: Colors.grey[600])))
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 60, // donut style
                          sections: data.entries.map((e) {
                            return PieChartSectionData(
                              value: e.value.toDouble(),
                              title: '',
                              color: _getCategoryColor(e.key),
                              radius: 100,
                            );
                          }).toList(),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${data.values.fold<int>(0, (s, v) => s + v)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          Text('Total', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: data.entries.map((e) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(e.key),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${e.key} (${e.value})',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopContentCard(String title, List<Map<String, dynamic>> items, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text('No content available', style: TextStyle(color: Colors.grey[600]))),
            )
          else
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    // rank
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                      child: Center(
                        child: Text('${index + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // title + category
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']?.toString() ?? 'Untitled',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(item['category']?.toString() ?? 'Uncategorized', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    // views pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.visibility, size: 14, color: color),
                          const SizedBox(width: 4),
                          Text('${item['views_count'] ?? 0}', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    // Distinct colors for each category
    final categoryColors = {
      'laptop': const Color(0xFF3498DB),      // Blue
      'battery': const Color(0xFFF39C12),     // Orange
      'cable': const Color(0xFF27AE60),       // Green
      'general': const Color(0xFF95A5A6),     // Gray
      'smartphone': const Color(0xFF9B59B6),  // Purple
      'tablet': const Color(0xFF16A085),      // Teal
      'charger': const Color(0xFFE74C3C),     // Red
      'headphones': const Color(0xFFE67E22),  // Dark Orange
      'monitor': const Color(0xFF2980B9),     // Dark Blue
      'keyboard': const Color(0xFF8E44AD),    // Dark Purple
    };
    return categoryColors[category.toLowerCase()] ?? const Color(0xFF7F8C8D); // Default gray
  }
}
