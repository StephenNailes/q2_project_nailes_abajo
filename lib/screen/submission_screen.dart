import 'package:flutter/material.dart';
import '../components/eco_bottom_nav.dart';
import '../components/shared/swipe_nav_wrapper.dart';
import '../components/submission/new_submission_card.dart';
import '../components/submission/checklist_card.dart';
import '../components/submission/step1_select.dart';

class SubmissionScreen extends StatelessWidget {
  const SubmissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SwipeNavWrapper(
      currentIndex: 3,
      child: Container(
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
                "Submission Hub",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
          child: Column(
            children: [
              NewSubmissionCard(
                onSubmit: () {
                  // Navigate to Step 1 (Select Item)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Step1Select(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              const ChecklistCard(
                title: "Before you submit",
                items: [
                  "Remove personal data before submitting",
                  "Include all accessories and cables",
                  "Take clear photos of the device",
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        bottomNavigationBar: const EcoBottomNavBar(currentIndex: 3),
        floatingActionButton: const SubmissionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ), // Scaffold
    ), // Container
  ); // SwipeNavWrapper
  }
}
