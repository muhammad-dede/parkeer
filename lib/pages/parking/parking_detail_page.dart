import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkeer/core/constants/app_colors.dart';
import 'package:parkeer/models/parking_transaction.dart';
import 'package:parkeer/repositories/parking_transaction_repository.dart';
import 'package:parkeer/pages/print_nota/print_nota_page.dart';

class ParkingDetailPage extends StatefulWidget {
  const ParkingDetailPage({super.key, required this.transactionId});

  final int transactionId;

  @override
  State<ParkingDetailPage> createState() => _ParkingDetailPageState();
}

class _ParkingDetailPageState extends State<ParkingDetailPage> {
  final _repository = ParkingTransactionRepository.instance;

  final currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

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

  ParkingTransaction? _transaction;
  bool _loading = true;
  bool _isActive = false;
  double _parkingFee = 0;
  DateTime _exitTime = DateTime.now();
  bool _hasChanged = false;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
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

    final exitTime = transaction.status == 'OUT'
        ? transaction.exitTime!
        : DateTime.now();

    final parkingFee = transaction.status == 'OUT'
        ? transaction.totalFee
        : await _repository.calculateParkingFee(
            transactionId: widget.transactionId,
            exitTime: exitTime,
          );

    if (!mounted) return;

    setState(() {
      _transaction = transaction;
      _parkingFee = parkingFee;
      _exitTime = exitTime;
      _isActive = transaction.status == 'IN';
      _loading = false;
    });
    // debugPrint(_transaction?.toMap().toString());
  }

  Future<void> _showCompleteTransaction() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Selesaikan Parkir"),
          content: const Text(
            "Yakin ingin menyelesaikan transaksi parkir ini?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Tidak"),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Selesai"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await _repository.completeTransaction(
      transactionId: widget.transactionId,
      exitTime: _exitTime,
      totalFee: _parkingFee.toInt(),
    );

    if (!mounted) return;

    _hasChanged = true;
    await _loadTransaction();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Transaksi parkir berhasil diselesaikan.")),
    );
  }

  Future<void> _showCancelDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Batalkan Parkir"),
          content: const Text("Yakin ingin membatalkan transaksi parkir ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Tidak"),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Ya, Batalkan"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await _repository.deleteTransaction(widget.transactionId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Transaksi parkir berhasil dihapus.")),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        Navigator.pop(context, _hasChanged);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Detail Parkir")),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PrintNotaPage(
                            transactionId: widget.transactionId,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.print),
                    label: const Text("Cetak Nota"),
                  ),
                ),

                if (_isActive) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      onPressed: _showCompleteTransaction,
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        "Selesaikan Parkir",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _showCancelDialog,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text(
                        "Batalkan Parkir",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ],
            ),
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
              transaction.status == 'IN' ? "Aktif" : 'Selesai',
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
          _infoRow(
            "Masuk",
            DateFormat(
              'dd MMM yyyy HH:mm',
              'id_ID',
            ).format(transaction.entryTime),
          ),
          if (!_isActive) ...[
            _divider(),
            _infoRow(
              "Keluar",
              DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(_exitTime),
            ),
          ],
          _divider(),
          _infoRow(
            "Durasi",
            formatDuration(
              transaction.entryTime,
              exitTime: _isActive ? _exitTime : transaction.exitTime,
            ),
          ),
          _divider(),
          _infoRow("Tarif Minimum", currency.format(transaction.minimumCharge)),
          _divider(),
          _infoRow(
            "Maksimal Harian",
            currency.format(transaction.maximumDailyCharge),
          ),
        ],
      ),
    );
  }

  Widget _feeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            _isActive ? "Estimasi Biaya" : "Total Bayar",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currency.format(_parkingFee),
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
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
