import 'package:flutter/material.dart';

class HistorySearch extends StatelessWidget {
  final ValueChanged<String>? onChanged;

  const HistorySearch({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: "Cari nomor polisi / tiket...",
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}
