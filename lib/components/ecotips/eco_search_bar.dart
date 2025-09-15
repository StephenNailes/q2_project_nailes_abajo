import 'package:flutter/material.dart';

class EcoSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onClear;

  const EcoSearchBar({
    super.key,
    required this.controller,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(30),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, child) {
          return TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Search tips",
              hintStyle: const TextStyle(color: Colors.black38, fontSize: 16),
              prefixIcon: const Icon(Icons.search, color: Colors.green),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.black38),
                      onPressed: onClear,
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.white,
              filled: true,
            ),
            style: const TextStyle(fontSize: 16),
          );
        },
      ),
    );
  }
}
