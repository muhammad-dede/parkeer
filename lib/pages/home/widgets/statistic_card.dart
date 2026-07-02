import 'package:flutter/material.dart';

class StatisticCard extends StatelessWidget {
  const StatisticCard({
    super.key,
    required this.vehicleToday,
    required this.incomeToday,
  });

  final int vehicleToday;
  final String incomeToday;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            title: "Masuk Hari Ini",
            value: vehicleToday.toString(),
            subtitle: "Kendaraan",
            icon: Icons.login_outlined,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _statCard(
            title: "Pendapatan Hari Ini",
            value: incomeToday,
            subtitle: "Total Pendapatan",
            icon: Icons.account_balance_wallet_outlined,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
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
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
