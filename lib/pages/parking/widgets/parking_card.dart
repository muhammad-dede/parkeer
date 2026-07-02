import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkeer/core/constants/app_colors.dart';
import 'package:parkeer/models/parking_transaction.dart';

class ParkingCard extends StatelessWidget {
  const ParkingCard({super.key, required this.transaction});

  final ParkingTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy • HH:mm', 'id_ID');

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
              ],
            ),
          ),

          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
