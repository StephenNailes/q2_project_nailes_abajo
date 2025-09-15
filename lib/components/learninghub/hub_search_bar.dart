import 'package:flutter/material.dart';

class HubSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback? onClear;

  const HubSearchBar({
    super.key,
    this.controller,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(30),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: "Search Guides",
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 16),
          prefixIcon: const Icon(Icons.search, color: Colors.green),
          suffixIcon: controller != null && controller!.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.black38),
                  onPressed: onClear,
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          fillColor: Colors.white,
          filled: true,
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
