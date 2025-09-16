import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'settings_sub_screen.dart';

class ManageEmailScreen extends StatefulWidget {
  const ManageEmailScreen({Key? key}) : super(key: key);

  @override
  State<ManageEmailScreen> createState() => _ManageEmailScreenState();
}

class _ManageEmailScreenState extends State<ManageEmailScreen> {
  final TextEditingController _current = TextEditingController();
  final TextEditingController _newEmail = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _newEmail.dispose();
    super.dispose();
  }

  void _save() {
    final curr = _current.text.trim();
    final neu = _newEmail.text.trim();
    if (curr.isEmpty || neu.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    // TODO: validate and update email via API
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email updated')));
    context.go('/settings');
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSubScreen(
      title: 'Manage Email',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Current Email', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _current,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'current@example.com',
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          const Text('New Email', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _newEmail,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'new@example.com',
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
