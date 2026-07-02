import 'dart:async';
import 'package:flutter/material.dart';
import 'package:parkeer/core/events/app_event_bus.dart';
import 'package:parkeer/core/events/transaction_changed_event.dart';
import 'package:parkeer/models/parking_transaction.dart';
import 'package:parkeer/pages/parking/parking_create_page.dart';
import 'package:parkeer/pages/parking/parking_detail_page.dart';
import 'package:parkeer/pages/parking/widgets/parking_card.dart';
import 'package:parkeer/pages/parking/widgets/parking_fab.dart';
import 'package:parkeer/pages/parking/widgets/parking_search.dart';
import 'package:parkeer/pages/scan_qr/scan_qr_page.dart';
import 'package:parkeer/repositories/parking_transaction_repository.dart';
import 'package:parkeer/widgets/empty_state.dart';

class ParkingPage extends StatefulWidget {
  const ParkingPage({super.key});

  @override
  State<ParkingPage> createState() => _ParkingPageState();
}

class _ParkingPageState extends State<ParkingPage> {
  late final StreamSubscription _subscription;

  final ScrollController _scrollController = ScrollController();

  final _repository = ParkingTransactionRepository.instance;

  List<ParkingTransaction> _transactions = [];

  static const int _pageSize = 10;

  bool _loading = true;

  bool _isLoadingMore = false;

  bool _hasMore = true;

  String _keyword = '';

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    _loadTransactions(reset: true);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_loading &&
          !_isLoadingMore &&
          _hasMore) {
        _loadTransactions();
      }
    });

    _subscription = AppEventBus.instance.on<TransactionChangedEvent>().listen((
      _,
    ) {
      _loadTransactions(reset: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    await _loadTransactions(reset: true);
  }

  Future<void> _loadTransactions({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _hasMore = true;
        _transactions.clear();
      });
    } else {
      _isLoadingMore = true;
    }

    final result = await _repository.getActiveTransactions(
      keyword: _keyword,
      limit: _pageSize,
      offset: _transactions.length,
    );

    if (!mounted) return;

    setState(() {
      if (reset) {
        _transactions = result;
        _loading = false;
      } else {
        _transactions.addAll(result);
      }
      _hasMore = result.length == _pageSize;
      _isLoadingMore = false;
    });
  }

  void _onSearchChanged(String value) {
    _keyword = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _loadTransactions(reset: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Parkir')),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ParkingFab(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ParkingCreatePage()),
          );
        },
      ),

      body: Column(
        children: [
          const SizedBox(height: 12),

          ParkingSearch(
            onChanged: _onSearchChanged,
            onScan: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScanQrPage()),
              );
            },
          ),

          const SizedBox(height: 12),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _transactions.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        EmptyState(
                          icon: _keyword.trim().isEmpty
                              ? Icons.local_parking_outlined
                              : Icons.search_off,
                          title: _keyword.trim().isEmpty
                              ? "Belum ada kendaraan parkir"
                              : "Data tidak ditemukan",
                          subtitle: _keyword.trim().isEmpty
                              ? "Belum ada kendaraan yang sedang parkir. Tambahkan transaksi baru untuk memulai."
                              : "Tidak ada kendaraan parkir yang sesuai dengan kata kunci \"$_keyword\".",
                        ),
                      ],
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 65),
                      itemCount: _transactions.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _transactions.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final transaction = _transactions[index];

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ParkingDetailPage(
                                  transactionId: transaction.id!,
                                ),
                              ),
                            );
                          },
                          child: ParkingCard(transaction: transaction),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
