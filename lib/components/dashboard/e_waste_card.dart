import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // <-- Add this line

class EWasteCard extends StatelessWidget {
  final VoidCallback onSubmit;

  const EWasteCard({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 6,
      shadowColor: Colors.orangeAccent.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: const [
                Icon(Icons.delete_outline, color: Colors.orange, size: 26),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "E-Waste Submission",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Ready to dispose of your electronic waste responsibly? Upload details and we'll help you find the best disposal options.",
              style: TextStyle(color: Colors.black87, fontSize: 15),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Use go_router navigation
                  context.go('/submissions');
                  onSubmit();
                },
                icon: const Icon(Icons.upload_file, size: 18),
                label: const Text(
                  "+ Submit E-Waste",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
