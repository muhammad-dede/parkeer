import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:parkeer/core/constants/app_colors.dart';
import 'package:parkeer/pages/history/history_detail_page.dart';
import 'package:parkeer/pages/parking/parking_detail_page.dart';
import 'package:parkeer/repositories/parking_transaction_repository.dart';

class ScanQrPage extends StatefulWidget {
  const ScanQrPage({super.key});

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcode = capture.barcodes.firstOrNull;

    if (barcode == null) return;

    final value = barcode.rawValue;

    if (value == null || value.isEmpty) return;

    _isProcessing = true;

    await _controller.stop();

    final transaction = await ParkingTransactionRepository.instance
        .getTransactionByTicketNumber(value);

    if (!mounted) return;

    if (transaction == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi tidak ditemukan')),
      );

      _isProcessing = false;
      await _controller.start();
      return;
    }

    // ===== Navigasi =====
    if (transaction.status == 'IN') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ParkingDetailPage(transactionId: transaction.id!),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HistoryDetailPage(transactionId: transaction.id!),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR Code"),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),

          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                "Arahkan kamera ke QR Code tiket parkir",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
