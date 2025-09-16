import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'settings_sub_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _current = TextEditingController();
  final TextEditingController _newPass = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _newPass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _save() {
    final newPass = _newPass.text.trim();
    final confirm = _confirm.text.trim();

    if (newPass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    if (newPass != confirm) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('New passwords do not match')));
      return;
    }

    // TODO: call change password API or local logic
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Password changed')));
    context.go('/settings');
  }

  @override
  Widget build(BuildContext context) {
    return SettingsSubScreen(
      title: 'Change Password',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Current Password', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _current,
            obscureText: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Current password',
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          const Text('New Password', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _newPass,
            obscureText: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'New password',
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Confirm New Password', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _confirm,
            obscureText: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Confirm new password',
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
