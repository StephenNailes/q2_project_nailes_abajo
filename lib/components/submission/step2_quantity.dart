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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: const Color(0xFFF8F9FB),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StepperHeader(currentStep: 2),
            const SizedBox(height: 32),

            Text(
              "How many items are you recycling?",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Select the quantity of items you want to recycle",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 32),

            // Quantity counter
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _modernCircleButton(Icons.remove, () {
                    setState(() {
                      if (quantity > 1) quantity--;
                    });
                  }),
                  const SizedBox(width: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      "$quantity",
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  _modernCircleButton(Icons.add, () {
                    setState(() {
                      quantity++;
                    });
                  }),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                "Items",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.black45,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Info note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade400, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "You can add multiple items of the same type. Each item will be processed individually.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                        fontSize: 15,
                      ),
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
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                ),
                child: const Text("Continue"),
              ),
            ),
            const SizedBox(height: 8),
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
      title: const Text(
        "Recycle Items",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 19,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: Colors.grey.shade200,
          height: 1,
        ),
      ),
    );
  }

  Widget _modernCircleButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Icon(icon, color: Colors.black87, size: 24),
        ),
      ),
    );
  }
}
