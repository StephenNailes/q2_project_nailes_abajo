import 'package:flutter/material.dart';
import 'stepper_header.dart';
import 'step2_quantity.dart';

class Step1Select extends StatefulWidget {
  const Step1Select({super.key});

  @override
  State<Step1Select> createState() => _Step1SelectState();
}

class _Step1SelectState extends State<Step1Select> {
  String _selectedAction = 'Disposed'; // Default action

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
              "What are you disposing?",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Select the type of item you'd like to dispose or repurpose",
              style: TextStyle(
                color: Colors.black45,
                fontSize: 15,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(height: 24),

            // Action selector (Disposed/Repurposed)
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() => _selectedAction = 'Disposed');
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: _selectedAction == 'Disposed'
                            ? const LinearGradient(
                                colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                              )
                            : null,
                        color: _selectedAction != 'Disposed' ? Colors.white : null,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedAction == 'Disposed'
                              ? const Color(0xFF2ECC71)
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                        boxShadow: _selectedAction == 'Disposed'
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF2ECC71).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.recycling,
                            color: _selectedAction == 'Disposed'
                                ? Colors.white
                                : Colors.grey[600],
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Dispose',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: _selectedAction == 'Disposed'
                                  ? Colors.white
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() => _selectedAction = 'Repurposed');
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: _selectedAction == 'Repurposed'
                            ? const LinearGradient(
                                colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
                              )
                            : null,
                        color: _selectedAction != 'Repurposed' ? Colors.white : null,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedAction == 'Repurposed'
                              ? const Color(0xFF3498DB)
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                        boxShadow: _selectedAction == 'Repurposed'
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF3498DB).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.autorenew,
                            color: _selectedAction == 'Repurposed'
                                ? Colors.white
                                : Colors.grey[600],
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Repurpose',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: _selectedAction == 'Repurposed'
                                  ? Colors.white
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
            MaterialPageRoute(
              builder: (_) => Step2Quantity(
                itemType: title,
                action: _selectedAction,
              ),
            ),
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
        "Dispose Items",
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
