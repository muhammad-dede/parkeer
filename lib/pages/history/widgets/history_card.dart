import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkeer/core/constants/app_colors.dart';
import 'package:parkeer/models/parking_transaction.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({super.key, required this.transaction});

  final ParkingTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final dateFormat = DateFormat('dd/MM/yyyy • HH:mm', 'id_ID');

    final totalFee = transaction.totalFee;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(76, 175, 80, 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.motorcycle, color: AppColors.primary),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.plateNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  transaction.ticketNumber,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),

                const SizedBox(height: 3),

                Text(
                  "Masuk ${dateFormat.format(transaction.entryTime)}",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  "Keluar ${transaction.exitTime != null ? dateFormat.format(transaction.exitTime!) : '-'}",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Text(
            transaction.status == "IN" ? "" : currency.format(totalFee),
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(width: 8),

          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
