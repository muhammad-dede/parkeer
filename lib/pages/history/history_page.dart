import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkeer/core/events/app_event_bus.dart';
import 'package:parkeer/core/events/transaction_changed_event.dart';
import 'package:parkeer/core/utils/date_time_util.dart';
import 'package:parkeer/models/parking_transaction.dart';
import 'package:parkeer/pages/history/history_detail_page.dart';
import 'package:parkeer/pages/history/widgets/history_card.dart';
import 'package:parkeer/pages/history/widgets/history_summary.dart';
import 'package:parkeer/pages/history/widgets/history_search.dart';
import 'package:parkeer/repositories/parking_transaction_repository.dart';
import 'package:parkeer/widgets/empty_state.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late final StreamSubscription _subscription;

  final ScrollController _scrollController = ScrollController();

  final _repository = ParkingTransactionRepository.instance;

  List<ParkingTransaction> _histories = [];

  HistoryFilter _selectedFilter = HistoryFilter.today;

  static const int _pageSize = 10;

  bool _isLoadingMore = false;

  bool _hasMore = true;

  bool _loading = true;

  bool _changingFilter = false;

  String _keyword = '';

  Timer? _debounce;

  int _totalTransaction = 0;

  double _totalIncome = 0;

  DateTime? _startDate;
  DateTime? _endDate;

  String _formatGroupTitle(String date) {
    final d = DateTime.parse(date);
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final current = DateTime(d.year, d.month, d.day);

    if (current == today) {
      return "Hari Ini, ${DateTimeUtil.date(d)}";
    }

    if (current == yesterday) {
      return "Kemarin, ${DateTimeUtil.date(d)}";
    }

    return DateTimeUtil.date(d);
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void initState() {
    super.initState();

    _changeFilter(HistoryFilter.today);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_loading &&
          !_isLoadingMore &&
          _hasMore) {
        _loadHistories();
      }
    });

    _subscription = AppEventBus.instance.on<TransactionChangedEvent>().listen((
      _,
    ) {
      _loadHistories(reset: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _loadSummary() async {
    final summary = await _repository.getHistorySummary(
      keyword: _keyword,
      startDate: _startDate,
      endDate: _endDate,
    );

    if (!mounted) return;

    setState(() {
      _totalTransaction = summary['total_transaction'] as int;
      _totalIncome = (summary['total_income'] as num).toDouble();
    });
  }

  Future<void> _refresh() async {
    await _loadHistories(reset: true);
  }

  Future<void> _loadHistories({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _hasMore = true;
        _histories.clear();
      });
    } else {
      _isLoadingMore = true;
    }

    final result = await _repository.getHistories(
      keyword: _keyword,
      startDate: _startDate,
      endDate: _endDate,
      limit: _pageSize,
      offset: _histories.length,
    );

    if (reset) {
      await _loadSummary();
    }

    if (!mounted) return;

    setState(() {
      if (reset) {
        _histories = result;
        _loading = false;
      } else {
        _histories.addAll(result);
      }

      _hasMore = result.length == _pageSize;
      _isLoadingMore = false;
    });
  }

  void _onSearchChanged(String value) {
    _keyword = value;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _loadHistories(reset: true);
    });
  }

  void _changeFilter(HistoryFilter filter) async {
    final now = DateTime.now();

    switch (filter) {
      case HistoryFilter.today:
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = DateTime(now.year, now.month, now.day);
        break;

      case HistoryFilter.week:
        final monday = now.subtract(Duration(days: now.weekday - 1));
        _startDate = DateTime(monday.year, monday.month, monday.day);
        _endDate = now;
        break;

      case HistoryFilter.month:
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = now;
        break;

      case HistoryFilter.custom:
        final result = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          initialDateRange: _startDate != null && _endDate != null
              ? DateTimeRange(start: _startDate!, end: _endDate!)
              : null,
        );

        if (result == null) return;

        _startDate = result.start;
        _endDate = result.end;
        break;
    }

    setState(() {
      _selectedFilter = filter;
      _changingFilter = true;
    });

    await _loadHistories(reset: true);

    if (!mounted) return;

    setState(() {
      _changingFilter = false;
    });
  }

  bool get _isFiltering {
    return _selectedFilter != HistoryFilter.today || _keyword.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat')),
      body: Column(
        children: [
          const SizedBox(height: 12),

          HistorySearch(onChanged: _onSearchChanged),

          const SizedBox(height: 12),

          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ChoiceChip(
                  label: const Text("Hari Ini"),
                  selected: _selectedFilter == HistoryFilter.today,
                  onSelected: _changingFilter
                      ? null
                      : (_) => _changeFilter(HistoryFilter.today),
                ),

                const SizedBox(width: 8),

                ChoiceChip(
                  label: const Text("Minggu Ini"),
                  selected: _selectedFilter == HistoryFilter.week,
                  onSelected: _changingFilter
                      ? null
                      : (_) => _changeFilter(HistoryFilter.week),
                ),

                const SizedBox(width: 8),

                ChoiceChip(
                  label: const Text("Bulan Ini"),
                  selected: _selectedFilter == HistoryFilter.month,
                  onSelected: _changingFilter
                      ? null
                      : (_) => _changeFilter(HistoryFilter.month),
                ),

                const SizedBox(width: 8),

                ChoiceChip(
                  label: Text(
                    _selectedFilter == HistoryFilter.custom &&
                            _startDate != null &&
                            _endDate != null
                        ? "${DateFormat('dd/MM').format(_startDate!)} - ${DateFormat('dd/MM').format(_endDate!)}"
                        : "Pilih Tanggal",
                  ),
                  selected: _selectedFilter == HistoryFilter.custom,
                  onSelected: (_) => _changeFilter(HistoryFilter.custom),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          HistorySummary(
            totalTransaction: _totalTransaction,
            totalIncome: _totalIncome,
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _histories.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        EmptyState(
                          icon: _isFiltering ? Icons.search_off : Icons.history,
                          title: _isFiltering
                              ? "Riwayat tidak ditemukan"
                              : "Belum ada riwayat transaksi",
                          subtitle: _isFiltering
                              ? "Tidak ada transaksi yang sesuai dengan pencarian atau filter yang dipilih."
                              : "Transaksi yang telah selesai akan muncul di halaman ini.",
                        ),
                      ],
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 65),
                      itemCount: _histories.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _histories.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final history = _histories[index];

                        // Apakah perlu menampilkan header tanggal?
                        final showHeader =
                            index == 0 ||
                            !_isSameDate(
                              history.exitTime!,
                              _histories[index - 1].exitTime!,
                            );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showHeader)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 12,
                                  bottom: 8,
                                ),
                                child: Text(
                                  _formatGroupTitle(
                                    DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(history.exitTime!),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HistoryDetailPage(
                                      transactionId: history.id!,
                                    ),
                                  ),
                                );
                              },
                              child: HistoryCard(transaction: history),
                            ),
                          ],
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

enum HistoryFilter { today, week, month, custom }
