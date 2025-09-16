import 'package:flutter/material.dart';
import 'stepper_header.dart';

class Step5Review extends StatelessWidget {
  const Step5Review({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: const Color(0xFFF7F8FA),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StepperHeader(currentStep: 5),
            const SizedBox(height: 32),
            const Text(
              "Review and submit",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222B45),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please review your recycling log details before submitting.",
              style: TextStyle(
                color: Color(0xFF8F9BB3),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Request Summary",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: Color(0xFF222B45),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildSummaryItem(
                    icon: Icons.smartphone,
                    iconBg: Color(0xFFE3F0FF),
                    iconColor: Color(0xFF4285F4),
                    label: "Item Type",
                    value: "Mobile Phone",
                  ),
                  _divider(),
                  _buildSummaryItem(
                    icon: Icons.tag,
                    iconBg: Color(0xFFFFF3E3),
                    iconColor: Color(0xFFFFA726),
                    label: "Quantity",
                    value: "2 items",
                  ),
                  _divider(),
                  _buildSummaryItem(
                    icon: Icons.location_on,
                    iconBg: Color(0xFFE3FCEC),
                    iconColor: Color(0xFF34A853),
                    label: "Drop-off Location",
                    value: "Green Tech Center, Downtown",
                  ),
                  _divider(),
                  _buildPhotoSummaryItem(
                    imagePath: "lib/assets/images/apple-ip.jpg", // Replace with your asset path
                    label: "Photo Uploaded",
                    value: "apple-ip.jpg",
                  ),
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
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                child: const Text("Submit Log"),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                "Your recycled item will be saved to your history.",
                style: TextStyle(
                  color: Color(0xFF8F9BB3),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                    color: Color(0xFF222B45),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  )),
              Text(value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF8F9BB3),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSummaryItem({
    required String imagePath,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFFF7F8FA),
            shape: BoxShape.circle,
          ),
          child: Image.asset(imagePath, width: 22, height: 22, fit: BoxFit.contain),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                    color: Color(0xFF222B45),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  )),
              Text(value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFF8F9BB3),
                  )),
            ],
          ),
        ),
        Text(
          "View",
          style: const TextStyle(
            color: Color(0xFF2ECC71),
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return const Divider(height: 28, color: Color(0xFFF0F2F5), thickness: 1);
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF222B45)),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "Recycle Items",
        style: TextStyle(
          color: Color(0xFF222B45),
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
    );
  }
}
