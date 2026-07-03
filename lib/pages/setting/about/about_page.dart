import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:parkeer/widgets/section_title.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = "-";

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();

    if (!mounted) return;

    setState(() {
      _version = "${info.version} (${info.buildNumber})";
    });
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tentang Aplikasi")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 16),

          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Image.asset(
                "assets/images/parkeer_logo.png",
                width: 90,
                height: 90,
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Center(
            child: Text(
              "Parkeer",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 6),

          Center(
            child: Text(
              "Versi $_version",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),

          const SizedBox(height: 28),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Parkeer adalah aplikasi manajemen parkir yang membantu petugas dalam mencatat kendaraan masuk dan keluar, menghitung biaya parkir secara otomatis, serta menyimpan riwayat transaksi dengan cepat dan akurat.",
                textAlign: TextAlign.justify,
              ),
            ),
          ),

          const SizedBox(height: 20),

          SectionTitle(title: "Fitur Utama"),

          const SizedBox(height: 12),

          _buildTile(
            icon: Icons.login,
            title: "Kendaraan Masuk",
            subtitle: "Mencatat kendaraan yang memasuki area parkir.",
          ),

          _buildTile(
            icon: Icons.logout,
            title: "Kendaraan Keluar",
            subtitle: "Menghitung biaya parkir secara otomatis.",
          ),

          _buildTile(
            icon: Icons.history,
            title: "Riwayat Transaksi",
            subtitle: "Melihat seluruh transaksi parkir yang telah selesai.",
          ),

          _buildTile(
            icon: Icons.bar_chart,
            title: "Dashboard",
            subtitle: "Menampilkan statistik kendaraan dan pendapatan.",
          ),

          const SizedBox(height: 20),

          SectionTitle(title: "Pengembang"),

          const SizedBox(height: 12),

          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: const ListTile(
              leading: CircleAvatar(child: Icon(Icons.person)),
              title: Text("Muhammad Dede"),
              subtitle: Text("Flutter Developer"),
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: Text(
              "© 2026 Parkeer\nAll Rights Reserved",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
