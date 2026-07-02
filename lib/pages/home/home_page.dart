import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkeer/models/dashboard_summary.dart';
import 'package:parkeer/pages/home/widgets/quick_menu.dart';
import 'package:parkeer/pages/home/widgets/dashboard_card.dart';
import 'package:parkeer/pages/home/widgets/statistic_card.dart';
import 'package:parkeer/pages/home/widgets/summary_card.dart';
import 'package:parkeer/pages/scan_qr/scan_qr_page.dart';
import 'package:parkeer/repositories/parking_transaction_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onChangeTab});

  final ValueChanged<int> onChangeTab;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final repository = ParkingTransactionRepository.instance;

  DashboardSummary? summary;

  bool _loading = true;

  final currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    summary = await repository.getDashboardSummary();

    setState(() {
      _loading = false;
    });
  }

  Future<void> _refresh() async {
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actionsPadding: const EdgeInsets.only(right: 8),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScanQrPage()),
              );
            },
            icon: const Icon(Icons.qr_code_scanner_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        DashboardCard(parkingCount: summary?.parkingCount ?? 0),

                        const SizedBox(height: 16),

                        StatisticCard(
                          vehicleToday: summary?.vehicleInToday ?? 0,
                          incomeToday: currency.format(
                            summary?.incomeToday ?? 0,
                          ),
                        ),

                        const SizedBox(height: 24),

                        QuickMenu(
                          onChangeTab: widget.onChangeTab,
                          onRefreshHome: _load,
                        ),

                        const SizedBox(height: 24),

                        SummaryCard(
                          incomeToday: currency.format(
                            summary?.incomeToday ?? 0,
                          ),
                          incomeWeek: currency.format(summary?.incomeWeek ?? 0),
                          incomeMonth: currency.format(
                            summary?.incomeMonth ?? 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
