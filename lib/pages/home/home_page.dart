import 'dart:async';

import 'package:flutter/material.dart';
import 'package:parkeer/core/events/app_event_bus.dart';
import 'package:parkeer/core/events/transaction_changed_event.dart';
import 'package:parkeer/core/utils/currency_util.dart';
import 'package:parkeer/models/dashboard_summary.dart';
import 'package:parkeer/pages/home/widgets/quick_menu.dart';
import 'package:parkeer/pages/home/widgets/dashboard_card.dart';
import 'package:parkeer/pages/home/widgets/statistic_card.dart';
import 'package:parkeer/pages/home/widgets/summary_card.dart';
import 'package:parkeer/pages/qr_scan/qr_scan_page.dart';
import 'package:parkeer/repositories/parking_transaction_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onChangeTab});

  final ValueChanged<int> onChangeTab;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final StreamSubscription _subscription;

  final _repository = ParkingTransactionRepository.instance;

  DashboardSummary? _summary;

  bool _loading = true;

  Future<void> _loadDashboard() async {
    _summary = await _repository.getDashboardSummary();
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
                MaterialPageRoute(builder: (context) => const QrScanPage()),
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
                        DashboardCard(
                          parkingCount: _summary?.parkingCount ?? 0,
                        ),

                        const SizedBox(height: 16),

                        StatisticCard(
                          vehicleToday: _summary?.vehicleInToday ?? 0,
                          incomeToday: CurrencyUtil.format(
                            _summary?.incomeToday ?? 0,
                          ),
                        ),

                        const SizedBox(height: 24),

                        QuickMenu(
                          onChangeTab: widget.onChangeTab,
                          onRefreshHome: _loadDashboard,
                        ),

                        const SizedBox(height: 24),

                        SummaryCard(
                          incomeToday: CurrencyUtil.format(
                            _summary?.incomeToday ?? 0,
                          ),
                          incomeWeek: CurrencyUtil.format(
                            _summary?.incomeWeek ?? 0,
                          ),
                          incomeMonth: CurrencyUtil.format(
                            _summary?.incomeMonth ?? 0,
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
