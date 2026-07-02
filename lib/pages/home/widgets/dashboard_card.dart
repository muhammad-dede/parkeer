import 'package:flutter/material.dart';
import 'package:parkeer/core/constants/app_colors.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({super.key, required this.parkingCount});

  final int parkingCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Kendaraan Parkir",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    parkingCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Sedang parkir",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white24,
              child: Icon(
                Icons.motorcycle_sharp,
                color: Colors.white,
                size: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
