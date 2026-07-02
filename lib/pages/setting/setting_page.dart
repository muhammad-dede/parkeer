import 'package:flutter/material.dart';
import 'package:parkeer/pages/setting/about/about_page.dart';
import 'package:parkeer/pages/setting/backup_restore/backup_restore_page.dart';
import 'package:parkeer/pages/setting/outlet/outlet_page.dart';
import 'package:parkeer/pages/setting/parking_rate/parking_rate_page.dart';
import 'package:parkeer/pages/setting/widgets/setting_group.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 4),

          SettingGroup(
            title: "Pengaturan Umum",
            items: [
              SettingMenu(
                icon: Icons.payments_outlined,
                title: "Atur Tarif Parkir",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ParkingRatePage()),
                  );
                },
              ),
              SettingMenu(
                icon: Icons.store_outlined,
                title: "Informasi Outlet",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OutletPage()),
                  );
                },
              ),
              SettingMenu(
                icon: Icons.backup_outlined,
                title: "Backup & Restore",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BackupRestorePage(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          SettingGroup(
            title: "Lainnya",
            items: [
              SettingMenu(
                icon: Icons.info_outline,
                title: "Tentang Aplikasi",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutPage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
