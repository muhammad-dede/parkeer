import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistorySummary extends StatelessWidget {
  const HistorySummary({
    super.key,
    required this.totalTransaction,
    required this.totalIncome,
  });

  final int totalTransaction;
  final double totalIncome;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _statCard(
              title: "Transaksi",
              value: totalTransaction.toString(),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _statCard(
              title: "Pendapatan",
              value: NumberFormat.currency(
                locale: "id",
                symbol: "Rp ",
                decimalDigits: 0,
              ).format(totalIncome),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({required String title, required String value}) {
    return Card(
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 12, color: Colors.black)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
