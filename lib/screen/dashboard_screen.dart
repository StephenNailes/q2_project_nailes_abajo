import 'package:flutter/material.dart';
import '../components/eco_bottom_nav.dart';
import '../components/dashboard/items_recycled_card.dart';
import '../components/dashboard/eco_tip_card.dart';
import '../components/dashboard/e_waste_card.dart';
import '../components/dashboard/welcome_section.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.settings, color: Colors.black54),
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
                const WelcomeSection(
                  userName: "Kert", // later fetch from backend/user state
                  profileImage: "lib/assets/images/kert.jpg",
                ),

                const ItemsRecycledCard(count: "16"),
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
