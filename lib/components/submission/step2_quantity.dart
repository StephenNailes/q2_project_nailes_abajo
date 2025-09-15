import 'package:flutter/material.dart';
import 'stepper_header.dart';
import 'step3_dropoff.dart';

class Step2Quantity extends StatefulWidget {
  const Step2Quantity({super.key});

  @override
  State<Step2Quantity> createState() => _Step2QuantityState();
}

class _Step2QuantityState extends State<Step2Quantity> {
  int quantity = 1;

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
            const StepperHeader(currentStep: 2),
            const SizedBox(height: 24),

            const Text(
              "How many items are you recycling?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Select the quantity of items you want to recycle",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),

            // Quantity counter
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _circleButton(Icons.remove, () {
                  setState(() {
                    if (quantity > 1) quantity--;
                  });
                }),
                const SizedBox(width: 24),
                Text(
                  "$quantity",
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 24),
                _circleButton(Icons.add, () {
                  setState(() {
                    quantity++;
                  });
                }),
              ],
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text("Items",
                  style: TextStyle(color: Colors.black54, fontSize: 14)),
            ),
            const SizedBox(height: 24),

            // Info note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "You can add multiple items of the same type. Each item will be processed individually.",
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const Step3DropOff()));
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

  Widget _circleButton(IconData icon, VoidCallback onPressed) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey.shade200,
      child: IconButton(
        icon: Icon(icon, color: Colors.black),
        onPressed: onPressed,
      ),
    );
  }
}
