import 'package:flutter/material.dart';
import 'package:parkeer/core/constants/app_colors.dart';
import 'package:parkeer/core/services/printer_service.dart';
import 'package:parkeer/core/utils/date_time_util.dart';
import 'package:parkeer/models/outlet.dart';
import 'package:parkeer/models/parking_transaction.dart';
import 'package:parkeer/pages/parking/parking_detail_page.dart';
import 'package:parkeer/repositories/outlet_repository.dart';
import 'package:parkeer/repositories/parking_transaction_repository.dart';

class ParkingSuccessCreatePage extends StatefulWidget {
  const ParkingSuccessCreatePage({super.key, required this.transactionId});

  final int transactionId;

  @override
  State<ParkingSuccessCreatePage> createState() =>
      _ParkingSuccessCreatePageState();
}

class _ParkingSuccessCreatePageState extends State<ParkingSuccessCreatePage> {
  final _repository = ParkingTransactionRepository.instance;
  final _outletRepository = OutletRepository();

  Outlet _outlet = Outlet.empty();
  ParkingTransaction? _transaction;
  bool _loading = true;
  bool _isPrinting = false;

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

  Future<void> _handlePrintNota() async {
    setState(() => _isPrinting = true);
    try {
      final receiptBytes = PrinterService.generateParkingReceiptBytes(
        transaction: _transaction!,
        outlet: _outlet,
      );

      if (!mounted) return;

      await PrinterService.printReceipt(context: context, bytes: receiptBytes);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  Future<void> _handleViewDetail() async {
    final navigator = Navigator.of(context);
    await navigator.pushReplacement(
      MaterialPageRoute(
        builder: (_) => ParkingDetailPage(transactionId: widget.transactionId),
      ),
    );
  }

  void _handleBackToList() {
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: const BoxDecoration(
                                  color: Color(0xffE8F5E9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                  size: 64,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                "Kendaraan Berhasil Masuk",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _transaction!.plateNumber,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 32),
                              Card(
                                elevation: 0,
                                color: Colors.grey.shade100,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      _row(
                                        "No. Tiket",
                                        _transaction!.ticketNumber,
                                      ),
                                      const Divider(height: 28),
                                      _row(
                                        "Waktu Masuk",
                                        DateTimeUtil.dateTimeSlashDot(
                                          _transaction!.entryTime,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            onPressed: _isPrinting ? null : _handleViewDetail,
                            child: const Text(
                              "Lihat Detail",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: OutlinedButton.icon(
                            onPressed: _isPrinting ? null : _handlePrintNota,
                            icon: _isPrinting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.print),
                            label: Text(
                              _isPrinting ? "Mencetak..." : "Cetak Nota",
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: OutlinedButton(
                            onPressed: _isPrinting ? null : _handleBackToList,
                            child: const Text("Tutup"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _row(String title, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: const TextStyle(color: Colors.grey)),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
