import 'package:flutter/material.dart';

class StepperHeader extends StatelessWidget {
  final int currentStep;

  const StepperHeader({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Step $currentStep of 5",
            style: const TextStyle(color: Colors.black54, fontSize: 14)),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: currentStep / 5,
          color: const Color(0xFF2ECC71),
          backgroundColor: Colors.grey[300],
          minHeight: 5,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 16),

        // Steps row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStepCircle("1", "Select", currentStep >= 1),
            _buildStepCircle("2", "Quantity", currentStep >= 2),
            _buildStepCircle("3", "Drop Off", currentStep >= 3),
            _buildStepCircle("4", "Photo", currentStep >= 4),
            _buildStepCircle("5", "Submit", currentStep >= 5),
          ],
        ),
      ],
    );
  }

  static Widget _buildStepCircle(String number, String label, bool active) {
    return Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor:
              active ? const Color(0xFF2ECC71) : Colors.grey.shade300,
          child: active
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : Text(number,
                  style: const TextStyle(color: Colors.black54, fontSize: 14)),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? const Color(0xFF2ECC71) : Colors.black54,
          ),
        ),
      ],
    );
  }
}
