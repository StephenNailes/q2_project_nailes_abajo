import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/eco_bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE9FBEF), Color(0xFFD6F5E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // Profile Header with Gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 56, bottom: 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2ECC71), Color(0xFF5DD39E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 54,
                          backgroundImage: AssetImage("lib/assets/images/kert.jpg"),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: Implement edit profile picture
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Color(0xFF2ECC71), width: 2),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.edit, color: Color(0xFF2ECC71), size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "Kert Abajo",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "kert.abajo@email.com",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Profile Options Section
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Profile",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2ECC71),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Profile Options
                    _profileOption(
                      icon: Icons.bookmark,
                      iconColor: Color(0xFF2ECC71),
                      title: "Saved Tips",
                      onTap: () {},
                    ),
                    const SizedBox(height: 14),
                    _profileOption(
                      icon: Icons.note_alt_outlined,
                      iconColor: Color(0xFF5DADE2),
                      title: "My Submissions",
                      onTap: () {},
                    ),
                    const SizedBox(height: 14),
                    _profileOption(
                      icon: Icons.settings_outlined,
                      iconColor: Color(0xFFBB8FCE),
                      title: "Settings",
                      onTap: () {},
                    ),
                    const SizedBox(height: 14),
                    _profileOption(
                      icon: Icons.logout,
                      iconColor: Color(0xFFE74C3C),
                      title: "Log Out",
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text("Log Out"),
                              content: const Text("Are you sure you want to log out?"),
                              actions: [
                                TextButton(
                                  child: const Text("Cancel"),
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text("Log Out"),
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop(); // Close dialog
                                    // TODO: Add your logout logic here (e.g., clear user session)
                                    GoRouter.of(context).go('/login'); // Use GoRouter for navigation
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: const SubmissionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: const EcoBottomNavBar(currentIndex: 4),
      ),
    );
  }

  // Improved Profile Option Card
  Widget _profileOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF222222),
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}
