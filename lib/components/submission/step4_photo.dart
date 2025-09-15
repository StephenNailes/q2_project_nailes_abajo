import 'package:flutter/material.dart';
import 'stepper_header.dart';
import 'step5_submit.dart';

class Step4Photo extends StatelessWidget {
  const Step4Photo({super.key});

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
            const StepperHeader(currentStep: 4),
            const SizedBox(height: 24),

            const Text(
              "Upload a photo of your item",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Upload a photo of the recycled item for your records.",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // Upload box
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined,
                        color: Colors.black54, size: 40),
                    SizedBox(height: 8),
                    Text("Tap to upload or take a photo",
                        style: TextStyle(color: Colors.black54)),
                    SizedBox(height: 4),
                    Text("JPG, PNG up to 10MB",
                        style: TextStyle(color: Colors.black38, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tips
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Photo Tips",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 6),
                  Text("• Take photos in good lighting"),
                  Text("• Show the entire item clearly"),
                  Text("• Include any damage or wear"),
                ],
              ),
            ),

            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const Step5Review()));
                    },
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: const Text("Skip for now"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const Step5Review()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Continue"),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
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
