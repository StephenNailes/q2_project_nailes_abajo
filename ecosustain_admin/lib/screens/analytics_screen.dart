import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/supabase_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _service = AdminSupabaseService();
  
  bool _isLoading = true;
  int _totalVideos = 0;
  int _totalArticles = 0;
  int _totalVideoViews = 0;
  int _totalArticleViews = 0;
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
      // Fetch all data in parallel
      final results = await Future.wait([
        _service.getVideos(),
        _service.getArticles(),
      ]);
      
      final videos = results[0];
      final articles = results[1];
      
      // Calculate totals
      _totalVideos = videos.length;
      _totalArticles = articles.length;
      _totalVideoViews = videos.fold<int>(0, (sum, v) => sum + (v['views_count'] as int? ?? 0));
      _totalArticleViews = articles.fold<int>(0, (sum, a) => sum + (a['views_count'] as int? ?? 0));
      
      // Get top 5 most viewed videos
      final sortedVideos = List<Map<String, dynamic>>.from(videos);
      sortedVideos.sort((a, b) => (b['views_count'] as int? ?? 0).compareTo(a['views_count'] as int? ?? 0));
      _topVideos = sortedVideos.take(5).toList();
      
      // Get top 5 most viewed articles
      final sortedArticles = List<Map<String, dynamic>>.from(articles);
      sortedArticles.sort((a, b) => (b['views_count'] as int? ?? 0).compareTo(a['views_count'] as int? ?? 0));
      _topArticles = sortedArticles.take(5).toList();
      
      // Calculate category distribution for videos
      _videoCategoryDistribution = {};
      for (var video in videos) {
        final category = video['category']?.toString() ?? 'Uncategorized';
        _videoCategoryDistribution[category] = (_videoCategoryDistribution[category] ?? 0) + 1;
      }
      
      // Calculate category distribution for articles
      _articleCategoryDistribution = {};
      for (var article in articles) {
        final category = article['category']?.toString() ?? 'Uncategorized';
        _articleCategoryDistribution[category] = (_articleCategoryDistribution[category] ?? 0) + 1;
      }
      
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load analytics: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2ECC71),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Total Videos', _totalVideos.toString(), Icons.video_library, const Color(0xFF3498DB))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Total Articles', _totalArticles.toString(), Icons.article, const Color(0xFF9B59B6))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Video Views', _totalVideoViews.toString(), Icons.visibility, const Color(0xFFE74C3C))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Article Views', _totalArticleViews.toString(), Icons.remove_red_eye, const Color(0xFFF39C12))),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Charts Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Video Category Distribution
                      Expanded(
                        child: _buildCategoryChart(
                          'Video Categories',
                          _videoCategoryDistribution,
                          const Color(0xFF3498DB),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Article Category Distribution
                      Expanded(
                        child: _buildCategoryChart(
                          'Article Categories',
                          _articleCategoryDistribution,
                          const Color(0xFF9B59B6),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Top Content Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Videos
                      Expanded(
                        child: _buildTopContentCard(
                          'Top 5 Videos',
                          _topVideos,
                          Icons.video_library,
                          const Color(0xFF3498DB),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Top Articles
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
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
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
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(String title, Map<String, int> data, Color color) {
    if (data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            const Text('No data available'),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: data.entries.map((entry) {
                  final index = data.keys.toList().indexOf(entry.key);
                  return PieChartSectionData(
                    value: entry.value.toDouble(),
                    title: '${entry.value}',
                    color: _getColorForIndex(index, color),
                    radius: 100,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: data.entries.map((entry) {
              final index = data.keys.toList().indexOf(entry.key);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getColorForIndex(index, color),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    entry.key,
                    style: const TextStyle(fontSize: 12),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No content available')),
            )
          else
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Rank
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']?.toString() ?? 'Untitled',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['category']?.toString() ?? 'Uncategorized',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Views
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.visibility, size: 14, color: color),
                          const SizedBox(width: 4),
                          Text(
                            '${item['views_count'] ?? 0}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                              fontSize: 12,
                            ),
                          ),
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

  Color _getColorForIndex(int index, Color baseColor) {
    final colors = [
      baseColor,
      baseColor.withValues(alpha: 0.8),
      baseColor.withValues(alpha: 0.6),
      baseColor.withValues(alpha: 0.4),
      baseColor.withValues(alpha: 0.3),
    ];
    return colors[index % colors.length];
  }
}
