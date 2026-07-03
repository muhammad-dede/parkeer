import 'package:flutter/material.dart';
import 'package:parkeer/widgets/section_title.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.incomeToday,
    required this.incomeWeek,
    required this.incomeMonth,
  });

  final String incomeToday;
  final String incomeWeek;
  final String incomeMonth;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: "Ringkasan Pendapatan"),
        const SizedBox(height: 8),
        Card(
          shadowColor: Colors.black.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 20,
                ),
                leading: Icon(Icons.money),
                title: const Text(
                  "Pendapatan Hari Ini",
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Text(
                  incomeToday,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 20,
                ),
                leading: Icon(Icons.attach_money_outlined),
                title: const Text(
                  "Pendapatan Minggu Ini",
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Text(
                  incomeWeek,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 20,
                ),
                leading: Icon(Icons.monetization_on),
                title: const Text(
                  "Pendapatan Bulan Ini",
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Text(
                  incomeMonth,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
