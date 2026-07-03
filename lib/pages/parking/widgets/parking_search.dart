import 'package:flutter/material.dart';
import 'package:parkeer/widgets/form_text_field.dart';

class ParkingSearch extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onScan;

  const ParkingSearch({super.key, this.onChanged, this.onScan});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: FormTextField(
                onChanged: onChanged,
                hintText: "Cari nomor polisi / tiket...",
                prefixIcon: const Icon(Icons.search),
              ),
            ),

            const SizedBox(width: 10),

            InkWell(
              onTap: onScan,
              borderRadius: BorderRadius.circular(10),
              child: Ink(
                width: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(Icons.qr_code_scanner_outlined),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
