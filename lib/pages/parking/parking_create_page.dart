import 'package:flutter/material.dart';
import 'package:parkeer/core/constants/app_colors.dart';
import 'package:parkeer/core/utils/currency_util.dart';
import 'package:parkeer/core/utils/date_time_util.dart';
import 'package:parkeer/models/parking_rate.dart';
import 'package:parkeer/models/parking_rate_detail.dart';
import 'package:parkeer/models/parking_transaction.dart';
import 'package:parkeer/models/parking_transaction_detail.dart';
import 'package:parkeer/pages/parking/parking_detail_page.dart';
import 'package:parkeer/pages/parking/widgets/parking_success_bottom_sheet.dart';
import 'package:parkeer/repositories/parking_transaction_repository.dart';
import 'package:parkeer/pages/printer/printer_page.dart';

class ParkingCreatePage extends StatefulWidget {
  const ParkingCreatePage({super.key});

  @override
  State<ParkingCreatePage> createState() => _ParkingCreatePageState();
}

class _ParkingCreatePageState extends State<ParkingCreatePage> {
  final _repository = ParkingTransactionRepository.instance;
  ParkingRate? _rate;
  List<ParkingRateDetail> _rateDetails = [];

  bool _saving = false;

  final _formKey = GlobalKey<FormState>();

  final plateController = TextEditingController();

  String vehicleType = 'MOTOR';

  late DateTime entryTime;

  late String ticketNumber;

  String? _validatePlateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Nomor polisi wajib diisi";
    }

    final plate = value.trim().toUpperCase();

    final regex = RegExp(r'^[A-Z]{1,2}\s\d{1,4}\s[A-Z]{1,3}$');

    if (!regex.hasMatch(plate)) {
      return "Format nomor polisi tidak valid.\nContoh: B 1234 ABC";
    }

    return null;
  }

  @override
  void initState() {
    super.initState();

    entryTime = DateTime.now();

    ticketNumber = 'PKR${DateTimeUtil.timestamp(entryTime)}';

    _loadRate();
  }

  @override
  void dispose() {
    plateController.dispose();
    super.dispose();
  }

  Future<void> _loadRate() async {
    final rate = await _repository.getActiveRate(vehicleType);

    if (rate == null) {
      return;
    }

    final details = await _repository.getRateDetails(rate.id!);

    if (!mounted) return;

    setState(() {
      _rate = rate;
      _rateDetails = details;
    });
  }

  Future<void> _save() async {
    if (_saving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_rate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tarif parkir belum diatur")),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final transaction = ParkingTransaction(
        ticketNumber: ticketNumber,
        plateNumber: plateController.text.trim().toUpperCase(),
        vehicleTypeCode: vehicleType,
        entryTime: entryTime,
        exitTime: null,
        minimumCharge: _rate!.minimumCharge,
        maximumDailyCharge: _rate!.maximumDailyCharge,
        totalFee: 0,
        status: "IN",
      );

      final transactionId = await _repository.createTransaction(transaction);

      final detailSnapshots = _rateDetails.map((e) {
        return ParkingTransactionDetail(
          parkingTransactionId: transactionId,
          fromMinute: e.fromMinute,
          toMinute: e.toMinute,
          price: e.price,
        );
      }).toList();

      await _repository.createTransactionDetails(detailSnapshots);

      if (!mounted) return;

      await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        useSafeArea: false,
        enableDrag: false,
        isDismissible: false,
        showDragHandle: false,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        builder: (sheetContext) {
          final sheetNavigator = Navigator.of(sheetContext);
          final navigator = Navigator.of(context);

          return ParkingSuccessBottomSheet(
            transactionId: transactionId,
            ticketNumber: ticketNumber,
            plateNumber: plateController.text.trim().toUpperCase(),
            entryTime: entryTime,
            onPrintNota: () async {
              sheetNavigator.pop();
              final result = await navigator.push<bool>(
                MaterialPageRoute(
                  builder: (_) => PrinterPage(transactionId: transactionId),
                ),
              );
              if (!mounted) return;
              navigator.pop(result ?? true);
            },
            onBackToList: () {
              Navigator.of(sheetContext).pop();
              Navigator.of(context).pop(true);
            },
            onViewDetail: () async {
              sheetNavigator.pop();
              final result = await navigator.push<bool>(
                MaterialPageRoute(
                  builder: (_) =>
                      ParkingDetailPage(transactionId: transactionId),
                ),
              );
              if (!mounted) return;
              navigator.pop(result ?? true);
            },
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kendaraan Masuk")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRateCard(),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nomor Polisi",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: plateController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      hintText: "Contoh A 1234 AA",
                      prefixIcon: Icon(Icons.assignment),
                    ),
                    validator: _validatePlateNumber,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Gunakan spasi untuk pemisah huruf dan angka",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _infoParking(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Simpan",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRateCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(Icons.access_time_filled, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Pastikan tarif parkir sudah diatur pada menu pengaturan tarif.",
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoParking() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4),
          child: const Text(
            "Ringkasan",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          shadowColor: Colors.black.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 20,
                ),
                leading: Icon(Icons.money),
                title: const Text("No. Tiket", style: TextStyle(fontSize: 14)),
                trailing: Text(
                  ticketNumber,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 20,
                ),
                leading: Icon(Icons.lock_clock),
                title: const Text(
                  "Waktu Masuk",
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Text(
                  DateTimeUtil.dateTimeSlashDot(entryTime),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 20,
                ),
                leading: Icon(Icons.monetization_on),
                title: const Text(
                  "Tarif Minimum",
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Text(
                  _rate == null
                      ? "-"
                      : CurrencyUtil.format(_rate!.minimumCharge),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 20,
                ),
                leading: Icon(Icons.attach_money_outlined),
                title: const Text(
                  "Maksimal Harian",
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Text(
                  _rate?.maximumDailyCharge == null
                      ? "-"
                      : CurrencyUtil.format(_rate!.maximumDailyCharge ?? 0),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
