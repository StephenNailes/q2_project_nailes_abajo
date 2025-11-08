import 'package:flutter/material.dart';
import 'stepper_header.dart';
import 'step4_photo.dart';

class Step3DropOff extends StatefulWidget {
  final String itemType;
  final String action;
  final int quantity;

  const Step3DropOff({
    super.key,
    required this.itemType,
    required this.action,
    required this.quantity,
  });

  @override
  State<Step3DropOff> createState() => _Step3DropOffState();
}

class _Step3DropOffState extends State<Step3DropOff> {
  int _selectedIndex = 0;
  late String _currentAction;

  final List<_Location> _allLocations = [
    _Location(
      title: "SM City Davao E-Waste Collection",
      subtitle: "0.5 km • SM City Davao, Level 2",
      hours: "Open until 10 PM",
      rating: "4.8",
      services: ["Disposed"],
    ),
    _Location(
      title: "Davao Tech Refurbish Hub",
      subtitle: "1.2 km • 456 Bonifacio St",
      hours: "Open until 8 PM",
      rating: "4.9",
      services: ["Repurposed"],
    ),
    _Location(
      title: "Gaisano Mall Disposal Point",
      subtitle: "2.1 km • Gaisano Mall, Ground Floor",
      hours: "Open until 9 PM",
      rating: "4.6",
      services: ["Disposed"],
    ),
    _Location(
      title: "EcoCenter Repair Shop",
      subtitle: "2.8 km • 789 Roxas Avenue",
      hours: "Open until 7 PM",
      rating: "4.7",
      services: ["Repurposed"],
    ),
    _Location(
      title: "City Hall E-Waste Drop-off",
      subtitle: "3.5 km • City Hall Complex",
      hours: "Open until 6 PM",
      rating: "4.5",
      services: ["Disposed"],
    ),
    _Location(
      title: "GreenTech Refurbishing Center",
      subtitle: "4.2 km • 101 Tech Park Ave",
      hours: "Open until 8 PM",
      rating: "4.8",
      services: ["Repurposed"],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentAction = widget.action;
  }

  List<_Location> get _filteredLocations {
    return _allLocations
        .where((location) => location.services.contains(_currentAction))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredLocations = _filteredLocations;

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
            const SizedBox(height: 20),
            // Action selector buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: "Disposed",
                    icon: Icons.delete_outline,
                    isSelected: _currentAction == "Disposed",
                    onTap: () {
                      setState(() {
                        _currentAction = "Disposed";
                        _selectedIndex = 0; // Reset selection
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    label: "Repurposed",
                    icon: Icons.refresh,
                    isSelected: _currentAction == "Repurposed",
                    onTap: () {
                      setState(() {
                        _currentAction = "Repurposed";
                        _selectedIndex = 0; // Reset selection
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Info box showing filtered count
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2ECC71).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Color(0xFF2ECC71),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Showing ${filteredLocations.length} location${filteredLocations.length != 1 ? 's' : ''} for $_currentAction",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF222B45),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredLocations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No locations available",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Try switching to ${_currentAction == 'Disposed' ? 'Repurposed' : 'Disposed'}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredLocations.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final location = filteredLocations[index];
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
                onPressed: filteredLocations.isEmpty
                    ? null
                    : () {
                        final selectedLocation =
                            filteredLocations[_selectedIndex];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Step4Photo(
                              itemType: widget.itemType,
                              action: _currentAction,
                              quantity: widget.quantity,
                              location: selectedLocation.title,
                            ),
                          ),
                        );
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

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2ECC71) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2ECC71)
                : const Color(0xFFE4E9F2),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2ECC71).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF8F9BB3),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF8F9BB3),
              ),
            ),
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
        "Dispose Items",
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
  final List<String> services;

  const _Location({
    required this.title,
    required this.subtitle,
    required this.hours,
    required this.rating,
    required this.services,
  });
}
