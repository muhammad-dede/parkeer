import 'package:flutter/material.dart';
import 'package:parkeer/pages/parking/parking_create_page.dart';

class QuickMenu extends StatelessWidget {
  const QuickMenu({
    super.key,
    required this.onChangeTab,
    required this.onRefreshHome,
  });

  final ValueChanged<int> onChangeTab;
  final Future<void> Function() onRefreshHome;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            "Menu Cepat",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _menuItem(
              Icons.login,
              "Masuk",
              onTap: () {
                Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const ParkingCreatePage()),
                );
              },
            ),
            _menuItem(
              Icons.local_parking_outlined,
              "Parkir",
              onTap: () => onChangeTab(1),
            ),
            _menuItem(
              Icons.timer_outlined,
              "Riwayat",
              onTap: () => onChangeTab(2),
            ),
            _menuItem(
              Icons.settings_outlined,
              "Pengaturan",
              onTap: () => onChangeTab(3),
            ),
          ],
        ),
      ],
    );
  }

  Widget _menuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return Card(
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
