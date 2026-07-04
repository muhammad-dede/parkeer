import 'package:flutter/material.dart';
import 'package:parkeer/core/constants/app_colors.dart';
import 'package:parkeer/core/services/printer_service.dart';
import 'package:parkeer/core/utils/currency_util.dart';
import 'package:parkeer/core/utils/date_time_util.dart';
import 'package:parkeer/models/outlet.dart';
import 'package:parkeer/models/parking_transaction.dart';
import 'package:parkeer/repositories/outlet_repository.dart';
import 'package:parkeer/repositories/parking_transaction_repository.dart';

class HistoryDetailPage extends StatefulWidget {
  const HistoryDetailPage({super.key, required this.transactionId});

  final int transactionId;

  @override
  State<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage> {
  final _repository = ParkingTransactionRepository.instance;
  final _outletRepository = OutletRepository();

  Outlet _outlet = Outlet.empty();
  ParkingTransaction? _transaction;
  bool _loading = true;
  bool _isPrinting = false;

  String formatDuration(DateTime entryTime, {DateTime? exitTime}) {
    final endTime = exitTime ?? DateTime.now();
    final duration = endTime.difference(entryTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _loadTransaction();
    _loadOutlet();
  }

  Future<void> _loadTransaction() async {
    setState(() => _loading = true);

    final transaction = await _repository.getTransactionById(
      widget.transactionId,
    );

    if (transaction == null) {
      if (!mounted) return;
      Navigator.pop(context);
      return;
    }

    if (!mounted) return;

    setState(() {
      _transaction = transaction;
      _loading = false;
    });
  }

  Future<void> _loadOutlet() async {
    final outlet = await _outletRepository.get();
    if (!mounted) return;
    setState(() => _outlet = outlet);
  }

  Future<void> _actionPrint({bool forcePick = false}) async {
    setState(() => _isPrinting = true);
    try {
      final receiptBytes = PrinterService.generateParkingReceiptBytes(
        transaction: _transaction!,
        outlet: _outlet,
      );
      await PrinterService.printReceipt(
        context: context,
        bytes: receiptBytes,
        forcePickDevice: forcePick,
      );
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Riwayat")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _headerCard(),

                  const SizedBox(height: 16),

                  _informationCard(),

                  const SizedBox(height: 16),

                  _feeCard(),

                  const SizedBox(height: 30),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black12,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _isPrinting ? null : () => _actionPrint(),
                  icon: _isPrinting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.print),
                  label: Text(_isPrinting ? "Mencetak..." : "Cetak Nota"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerCard() {
    final transaction = _transaction!;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.motorcycle,
              color: AppColors.primary,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.plateNumber,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  transaction.ticketNumber,
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              'Selesai',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _informationCard() {
    final transaction = _transaction!;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          _divider(),
          _infoRow(
            "Masuk",
            DateTimeUtil.dateTimeSlashDot(transaction.entryTime),
          ),
          _infoRow(
            "Keluar",
            transaction.exitTime == null
                ? '-'
                : DateTimeUtil.dateTimeSlashDot(transaction.exitTime!),
          ),
          _infoRow(
            "Durasi",
            formatDuration(
              transaction.entryTime,
              exitTime: transaction.exitTime,
            ),
          ),
          _infoRow(
            "Tarif Minimum",
            CurrencyUtil.format(transaction.minimumCharge),
          ),
          _infoRow(
            "Maksimal Harian",
            CurrencyUtil.format(transaction.maximumDailyCharge ?? 0),
          ),
          _divider(),
        ],
      ),
    );
  }

  Widget _feeCard() {
    final transaction = _transaction!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Total Bayar',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            transaction.totalFee > 0
                ? CurrencyUtil.format(transaction.totalFee)
                : CurrencyUtil.format(0),
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(color: Colors.black)),
          ),
          Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(color: Colors.grey.shade200, height: 1);
  }
}
