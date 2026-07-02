import 'package:flutter/material.dart';
import 'package:parkeer/core/constants/app_colors.dart';
import 'package:parkeer/core/utils/currency_util.dart';
import 'package:parkeer/core/utils/date_time_util.dart';
import 'package:parkeer/models/outlet.dart';
import 'package:parkeer/models/parking_transaction.dart';
import 'package:parkeer/repositories/outlet_repository.dart';
import 'package:parkeer/repositories/parking_transaction_repository.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrinterPage extends StatefulWidget {
  const PrinterPage({super.key, required this.transactionId});

  final int transactionId;

  @override
  State<PrinterPage> createState() => _PrinterPageState();
}

class _PrinterPageState extends State<PrinterPage> {
  static const _lastPrinterAddressKey = 'last_printer_address';

  final _outletRepository = OutletRepository();

  Outlet _outlet = Outlet.empty();

  ReceiptController? controller;

  final _repository = ParkingTransactionRepository.instance;

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

  String? _savedPrinterAddress;
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.wait([_loadTransaction(), _loadSavedPrinter(), _loadOutlet()]);
  }

  Future<void> _loadOutlet() async {
    final outlet = await _outletRepository.get();

    if (!mounted) return;

    setState(() {
      _outlet = outlet;
    });
  }

  Future<void> _loadSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    final address = prefs.getString(_lastPrinterAddressKey);
    if (mounted && address != null) {
      setState(() => _savedPrinterAddress = address);
    }
  }

  Future<void> _forgetSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastPrinterAddressKey);
    if (mounted) setState(() => _savedPrinterAddress = null);
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
      _isActive = transaction.status.trim().toUpperCase() == 'IN';
      _loading = false;
    });
  }

  Future<void> _print({bool forcePickDevice = false}) async {
    if (controller == null || _isPrinting) return;

    setState(() => _isPrinting = true);

    try {
      String? address = forcePickDevice ? null : _savedPrinterAddress;

      address ??= (await FlutterBluetoothPrinter.selectDevice(
        context,
      ))?.address;

      if (address == null) return;

      final success = await controller!.print(
        address: address,
        keepConnected: true,
        addFeeds: 0,
      );

      if (!mounted) return;

      if (success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_lastPrinterAddressKey, address);
        setState(() => _savedPrinterAddress = address);
      } else {
        await _forgetSavedPrinter();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mencetak. Coba pilih printer lagi.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cetak Nota")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Receipt(
              builder: (context) {
                if (_isActive) {
                  return _buildEntryReceipt();
                }
                return _buildExitReceipt();
              },
              onInitialized: (controller) {
                controller.paperSize = PaperSize.mm58;
                this.controller = controller;
              },
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
                child: ElevatedButton.icon(
                  onPressed: _isPrinting ? null : () => _print(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  icon: _isPrinting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.print, color: Colors.white),
                  label: Text(
                    _isPrinting ? "Mencetak..." : "Cetak",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              if (_savedPrinterAddress != null && !_isPrinting) ...[
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => _print(forcePickDevice: true),
                  child: const Text("Ganti Printer"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotaHeader() {
    return Column(
      children: [
        Text(
          _outlet.name.isEmpty ? "PARKIR" : _outlet.name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        if (_outlet.address.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            _outlet.address,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],

        if (_outlet.phone.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            "Telp. ${_outlet.phone}",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],

        if (_outlet.email.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            _outlet.email,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],

        const SizedBox(height: 8),
        const Divider(color: Colors.black, thickness: 1.5, height: 16),
      ],
    );
  }

  Widget _buildEntryReceipt() {
    final trx = _transaction!;

    return Column(
      children: [
        const SizedBox(height: 20),
        _buildNotaHeader(),

        const Text(
          "TIKET MASUK",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const Divider(color: Colors.black, thickness: 1.5, height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "No Tiket",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              trx.ticketNumber,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "No Polisi",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              trx.plateNumber,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Masuk",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              DateTimeUtil.dateTimeSlash(trx.entryTime),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 16),

        QrImageView(
          data: trx.ticketNumber,
          size: 250,
          version: QrVersions.auto,
          gapless: true,
          errorCorrectionLevel: QrErrorCorrectLevel.M,
        ),

        const SizedBox(height: 16),

        const Text(
          "Scan QR Code saat keluar",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        const Text(
          "Terima kasih",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildExitReceipt() {
    final trx = _transaction!;

    return Column(
      children: [
        const SizedBox(height: 20),
        _buildNotaHeader(),

        const Text(
          "NOTA PEMBAYARAN",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const Divider(color: Colors.black, thickness: 1.5, height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "No Tiket",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              trx.ticketNumber,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "No Polisi",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              trx.plateNumber,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Masuk",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              DateTimeUtil.dateTimeSlash(trx.entryTime),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Keluar",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              DateTimeUtil.dateTimeSlash(trx.exitTime!),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Durasi",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              formatDuration(trx.entryTime, exitTime: trx.exitTime),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const Divider(color: Colors.black, thickness: 1.5, height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "TOTAL",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              CurrencyUtil.format(trx.totalFee),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 20),

        const Text(
          "Terima kasih",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        const Text(
          "Selamat Jalan",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 100),
      ],
    );
  }
}
