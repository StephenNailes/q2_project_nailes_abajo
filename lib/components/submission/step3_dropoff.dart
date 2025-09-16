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
      subtitle: "0.5 km • 123 Green Street",
      hours: "Open until 8 PM",
      rating: "4.8",
    ),
    _Location(
      title: "RecycleHub Mall",
      subtitle: "1.2 km • 456 Shopping Mall, L2",
      hours: "Open until 10 PM",
      rating: "4.6",
    ),
    _Location(
      title: "Green Point Station",
      subtitle: "2.1 km • 789 Metro Station",
      hours: "24/7 Available",
      rating: "4.4",
    ),
    _Location(
      title: "City Hall Collection",
      subtitle: "3.5 km • 101 City Hall Plaza",
      hours: "Open until 6 PM",
      rating: "4.2",
    ),
  ];

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
            const StepperHeader(currentStep: 3),
            const SizedBox(height: 28),
            const Text(
              "Choose drop-off location",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                color: Color(0xFF222B45),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Select a nearby center to continue",
              style: TextStyle(
                color: Color(0xFF8F9BB3),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: _locations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final location = _locations[index];
                  final isSelected = index == _selectedIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? const Color(0x1A2ECC71)
                              : const Color(0x0A222B45),
                          blurRadius: isSelected ? 12 : 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2ECC71)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? const Color(0xFF2ECC71)
                            : const Color(0xFFF7F8FA),
                        child: Icon(
                          Icons.location_on,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF2ECC71),
                        ),
                      ),
                      title: Text(
                        location.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isSelected
                              ? const Color(0xFF2ECC71)
                              : const Color(0xFF222B45),
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "${location.subtitle}\n${location.hours}",
                          style: const TextStyle(
                            color: Color(0xFF8F9BB3),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star,
                              color: Colors.amber.shade600, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            location.rating,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Color(0xFF222B45),
                            ),
                          ),
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Icon(Icons.check_circle,
                                  color: const Color(0xFF2ECC71), size: 22),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
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
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
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
