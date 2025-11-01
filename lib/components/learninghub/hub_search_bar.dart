import 'package:flutter/material.dart';

class HubSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final VoidCallback? onClear;

  const HubSearchBar({
    super.key,
    this.controller,
    this.onClear,
  });

  @override
  State<HubSearchBar> createState() => _HubSearchBarState();
}

class _HubSearchBarState extends State<HubSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {}); // Rebuild to show/hide clear button
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(30),
      child: TextField(
        controller: widget.controller,
        decoration: InputDecoration(
          hintText: "Search by title or topics...",
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 16),
          prefixIcon: const Icon(Icons.search, color: Colors.green),
          suffixIcon: widget.controller != null && widget.controller!.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.black38),
                  onPressed: widget.onClear,
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
