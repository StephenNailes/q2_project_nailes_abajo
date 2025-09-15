import 'package:flutter/material.dart';
import 'stepper_header.dart';

class Step5Review extends StatelessWidget {
  const Step5Review({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: const Color(0xFFF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StepperHeader(currentStep: 5),
            const SizedBox(height: 24),

            const Text(
              "Review and submit",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Please review your recycling log details before submitting.",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // Request summary card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 4))
                  ]),
              child: Column(
                children: [
                  _buildSummaryItem(Icons.smartphone, "Item Type", "Mobile Phone"),
                  _divider(),
                  _buildSummaryItem(Icons.confirmation_num_outlined, "Quantity", "2 items"),
                  _divider(),
                  _buildSummaryItem(Icons.location_on, "Drop-off Location", "Green Tech Center, Downtown"),
                  _divider(),
                  _buildSummaryItem(Icons.image, "Photo Uploaded", "IMG_2024.jpg", trailing: const Text("View", style: TextStyle(color: Colors.blue))),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Submit Log"),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                "Your recycled item will be saved to your history.",
                style: TextStyle(color: Colors.black54),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value,
      {Widget? trailing}) {
    return Row(
      children: [
        Icon(icon, color: Colors.black54),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.black54, fontSize: 12)),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _divider() {
    return Divider(height: 20, color: Colors.grey.shade300);
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text("Recycle Items",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
      centerTitle: true,
    );
  }
}
