import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsSubScreen extends StatelessWidget {
  final String title;
  final Widget child;

  const SettingsSubScreen({
    Key? key,
    required this.title,
    required this.child,
  }) : super(key: key);

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
            onPressed: () => context.go('/settings'),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}
