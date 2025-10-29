import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/eco_bottom_nav.dart';
import '../components/dashboard/items_recycled_card.dart';
import '../components/dashboard/eco_tip_card.dart';
import '../components/dashboard/e_waste_card.dart';
import '../components/dashboard/welcome_section.dart';
import '../services/supabase_service.dart';
import '../models/user_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  UserModel? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final profile = await _supabaseService.getUserProfile(user.uid);
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'User';
    return fullName.split(' ').first;
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
                "TechSustain",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.notifications, color: Colors.black54),
                onPressed: () => context.go('/notifications'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: const Icon(Icons.settings, color: Colors.black54),
                onPressed: () => context.go('/settings'),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox.expand(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👋 Welcome Section
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : WelcomeSection(
                        userName: _getFirstName(_userProfile?.name),
                        profileImageUrl: _userProfile?.profileImageUrl,
                      ),

                ItemsRecycledCard(
                  count: _userProfile?.totalRecycled.toString() ?? "0",
                ),
                const SizedBox(height: 24),

                Flexible(
                  child: EcoTipCarousel(
                    tips: [
                      EcoTip(
                        tip: "Switch to LED bulbs to reduce energy consumption by up to 80%",
                        icon: Icons.lightbulb_outline,
                        iconColor: Colors.orange,
                      ),
                      EcoTip(
                        tip: "Donate or recycle old electronics responsibly to prevent harmful e-waste from ending up in landfills.",
                        icon: Icons.shopping_bag_outlined,
                        iconColor: Colors.green,
                      ),
                      EcoTip(
                        tip: "Repurpose or refurbish broken gadgets to extend their life and reduce electronic waste.",
                        icon: Icons.grass,
                        iconColor: Colors.brown,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                EWasteCard(onSubmit: () {
                               }),
                const SizedBox(height: 24),
                
              ],
            ),
          ),
        ),
        floatingActionButton: const SubmissionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: const EcoBottomNavBar(currentIndex: 0),
      ),
    );
  }
}
