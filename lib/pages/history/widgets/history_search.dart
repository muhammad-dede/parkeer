import 'package:flutter/material.dart';
import 'package:parkeer/widgets/form_text_field.dart';

class HistorySearch extends StatelessWidget {
  final ValueChanged<String>? onChanged;

  const HistorySearch({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FormTextField(
        onChanged: onChanged,
        hintText: "Cari nomor polisi / tiket...",
        prefixIcon: const Icon(Icons.search),
      ),
    );
  }
}
