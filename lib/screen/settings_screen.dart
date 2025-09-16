import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _language = "English";

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Select Language",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text("English"),
                onTap: () {
                  setState(() => _language = "English");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text("Tagalog"),
                onTap: () {
                  setState(() => _language = "Tagalog");
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.go('/profile'),
          ),
          title: const Text(
            "Settings",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle("Account"),
            _settingsOption(
              context,
              icon: Icons.person_outline,
              iconColor: Colors.blue,
              bgColor: Colors.blue.shade50,
              title: "Edit Profile",
              subtitle: "Update your name, picture and details",
              onTap: () => context.go('/settings/edit-profile'),
            ),
            _settingsOption(
              context,
              icon: Icons.lock_outline,
              iconColor: Colors.green,
              bgColor: Colors.green.shade50,
              title: "Change Password",
              subtitle: "Update your login credentials",
              onTap: () => context.go('/settings/change-password'),
            ),
            _settingsOption(
              context,
              icon: Icons.email_outlined,
              iconColor: Colors.purple,
              bgColor: Colors.purple.shade50,
              title: "Manage Email",
              subtitle: "Change or verify your email address",
              onTap: () => context.go('/settings/manage-email'),
            ),
            const SizedBox(height: 24),

            _sectionTitle("Preferences"),
            _toggleOption(
              icon: Icons.notifications_outlined,
              iconColor: Colors.orange,
              bgColor: Colors.orange.shade50,
              title: "Notifications",
              value: _notificationsEnabled,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),
            _settingsOption(
              context,
              icon: Icons.language,
              iconColor: Colors.teal,
              bgColor: Colors.teal.shade50,
              title: "Language",
              subtitle: _language,
              trailing:
                  const Icon(Icons.arrow_drop_down, color: Colors.black54),
              onTap: _showLanguageSelector,
            ),
            const SizedBox(height: 24),

            _sectionTitle("Support"),
            _settingsOption(
              context,
              icon: Icons.help_outline,
              iconColor: Colors.yellow.shade700,
              bgColor: Colors.yellow.shade100,
              title: "Help Center",
              subtitle: "Get support and FAQs",
            ),
            _settingsOption(
              context,
              icon: Icons.shield_outlined,
              iconColor: Colors.pink,
              bgColor: Colors.pink.shade50,
              title: "Privacy Policy",
              subtitle: "Learn how we handle your data",
            ),
            _settingsOption(
              context,
              icon: Icons.info_outline,
              iconColor: Colors.blue,
              bgColor: Colors.blue.shade50,
              title: "About App",
              subtitle: "Version 1.0.0",
            ),
          ],
        ),
      ),
    );
  }

  // Section Title
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  // Card Option
  Widget _settingsOption(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  // Toggle Option
  Widget _toggleOption({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
          Switch(
            value: value,
            activeColor: Colors.green,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
