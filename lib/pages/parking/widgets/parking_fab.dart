import 'package:flutter/material.dart';
import 'package:parkeer/core/constants/app_colors.dart';

class ParkingFab extends StatelessWidget {
  final VoidCallback onPressed;

  const ParkingFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 48,
      child: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: onPressed,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Kendaraan Masuk",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
