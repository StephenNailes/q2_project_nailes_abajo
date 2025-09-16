import 'package:flutter/material.dart';
import 'stepper_header.dart';
import 'step2_quantity.dart';

class Step1Select extends StatelessWidget {
  const Step1Select({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: const Color(0xFFF8FAFB),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StepperHeader(currentStep: 1),
            const SizedBox(height: 32),

            const Text(
              "What are you recycling?",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Select the type of item you'd like to recycle",
              style: TextStyle(
                color: Colors.black45,
                fontSize: 15,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(height: 32),

            // Options
            _buildOption(
              context,
              Icons.smartphone,
              "Mobile Phone",
              "Smartphones",
            ),
            const SizedBox(height: 16),
            _buildOption(
              context,
              Icons.power,
              "Charger",
              "Phone chargers, cables, batteries",
            ),
            const SizedBox(height: 16),
            _buildOption(
              context,
              Icons.laptop_mac,
              "Laptop",
              "Laptops, tablets",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Step2Quantity()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF27AE60), size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black38,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.black26, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "Recycle Items",
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 19,
          letterSpacing: 0.1,
        ),
      ),
      centerTitle: true,
    );
  }
}
