import 'package:flutter/material.dart';

class ParkingSearch extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onScan;

  const ParkingSearch({super.key, this.onChanged, this.onScan});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: "Cari nomor polisi / tiket...",
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          const SizedBox(width: 10),

          InkWell(
            onTap: onScan,
            borderRadius: BorderRadius.circular(10),
            child: Ink(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.qr_code_scanner_outlined),
            ),
          ),
        ],
      ),
    );
  }
}
