import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/components/history/recycle_history_card.dart';

class RecycleHistoryScreen extends StatelessWidget {
  const RecycleHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyItems = [
      {
        "icon": Icons.smartphone,
        "color": Colors.blueAccent.shade100,
        "title": "iPhone 12 Pro",
        "quantity": "1 item",
        "location": "Best Buy - Downtown",
        "date": "March 15, 2024",
        "image": "lib/assets/images/apple-ip.jpg",
      },
      {
        "icon": Icons.cable,
        "color": Colors.greenAccent.shade100,
        "title": "USB-C Charger",
        "quantity": "2 items",
        "location": "Apple Store - Mall",
        "date": "March 12, 2024",
        "image": "lib/assets/images/charger.jpg",
      },
      {
        "icon": Icons.laptop_mac,
        "color": Colors.purpleAccent.shade100,
        "title": "MacBook Air 2019",
        "quantity": "1 item",
        "location": "Staples - North Branch",
        "date": "March 8, 2024",
        "image": "lib/assets/images/macbook.jpg",
      },
      {
        "icon": Icons.headphones,
        "color": Colors.orangeAccent.shade100,
        "title": "Wireless Headphones",
        "quantity": "1 item",
        "location": "Office Depot - Central",
        "date": "March 5, 2024",
        "image": "lib/assets/images/headphones.jpg",
      },
      {
        "icon": Icons.tablet_mac,
        "color": Colors.redAccent.shade100,
        "title": "iPad Mini",
        "quantity": "1 item",
        "location": "Best Buy - Westside",
        "date": "February 28, 2024",
        "image": "lib/assets/images/ipad.jpg",
      },
    ];

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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.go('/profile'),
          ),
          title: const Text(
            "Disposal History",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 20,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "View all the items you've logged for disposal or repurposing.",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: ListView.separated(
                    itemCount: historyItems.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = historyItems[index];
                      return RecycleHistoryCard(
                        icon: item["icon"] as IconData,
                        bgColor: item["color"] as Color,
                        title: item["title"] as String,
                        quantity: item["quantity"] as String,
                        location: item["location"] as String,
                        date: item["date"] as String,
                        imagePath: item["image"] as String,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
