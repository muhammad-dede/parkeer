import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkeer/core/events/app_event_bus.dart';
import 'package:parkeer/core/events/transaction_changed_event.dart';
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
  late final StreamSubscription _subscription;

  final repository = ParkingTransactionRepository.instance;

  DashboardSummary? summary;

  bool _loading = true;

  final currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Future<void> _loadDashboard() async {
    summary = await repository.getDashboardSummary();
    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    _subscription = AppEventBus.instance.on<TransactionChangedEvent>().listen((
      _,
    ) {
      _loadDashboard();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
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
                onRefresh: _loadDashboard,
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
                          onRefreshHome: _loadDashboard,
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
