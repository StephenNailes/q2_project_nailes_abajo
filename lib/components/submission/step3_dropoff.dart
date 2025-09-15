import 'package:flutter/material.dart';
import 'stepper_header.dart';
import 'step4_photo.dart';

class Step3DropOff extends StatefulWidget {
  const Step3DropOff({super.key});

  @override
  State<Step3DropOff> createState() => _Step3DropOffState();
}

class _Step3DropOffState extends State<Step3DropOff> {
  int _selectedIndex = 0;

  final List<_Location> _locations = [
    _Location(
      title: "EcoCenter Downtown",
      subtitle: "0.5 km away – Closest to you\n123 Green Street, Downtown District",
      hours: "Open until 8 PM",
      rating: "4.8",
    ),
    _Location(
      title: "RecycleHub Mall",
      subtitle: "1.2 km away\n456 Shopping Mall, Level 2, East Wing",
      hours: "Open until 10 PM",
      rating: "4.6",
    ),
    _Location(
      title: "Green Point Station",
      subtitle: "2.1 km away\n789 Metro Station, Ground Floor",
      hours: "24/7 Available",
      rating: "4.4",
    ),
    _Location(
      title: "City Hall Collection",
      subtitle: "3.5 km away\n101 City Hall Plaza, Main Entrance",
      hours: "Open until 6 PM",
      rating: "4.2",
    ),
  ];

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
            const StepperHeader(currentStep: 3),
            const SizedBox(height: 24),

            const Text(
              "Where would you like to drop off?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Choose your preferred drop-off location",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: _locations.length,
                itemBuilder: (context, index) {
                  final location = _locations[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    child: _buildLocationCard(
                      location.title,
                      location.subtitle,
                      location.hours,
                      location.rating,
                      index == _selectedIndex,
                    ),
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const Step4Photo()));
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

  Widget _buildLocationCard(String title, String subtitle, String hours,
      String rating, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
            color: isSelected ? const Color(0xFF2ECC71) : Colors.grey.shade300,
            width: 2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0x332ECC71),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              if (isSelected)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text("Selected",
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.black87)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(hours, style: const TextStyle(color: Colors.black54)),
              Row(
                children: [
                  const Icon(Icons.star,
                      color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(rating,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              )
            ],
          )
        ],
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

class _Location {
  final String title;
  final String subtitle;
  final String hours;
  final String rating;

  const _Location({
    required this.title,
    required this.subtitle,
    required this.hours,
    required this.rating,
  });
}
