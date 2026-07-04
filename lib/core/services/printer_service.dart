import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parkeer/core/utils/currency_util.dart';
import 'package:parkeer/core/utils/date_time_util.dart';
import 'package:parkeer/models/outlet.dart';
import 'package:parkeer/models/parking_transaction.dart';

class PrinterService {
  static const String _lastPrinterAddressKey = 'last_printer_address';

  /// Helper internal untuk menghitung durasi parkir
  static String _formatDuration(DateTime entryTime, {DateTime? exitTime}) {
    final endTime = exitTime ?? DateTime.now();
    final duration = endTime.difference(entryTime);

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Helper untuk generate printer command QR Code standard ESC/POS
  static List<int> _getQrByteCommand(String data) {
    List<int> bytes = [];
    int storeLen = data.length + 3;
    num lenByte1 = storeLen % 256;
    num lenByte2 = storeLen ~/ 256;

    bytes += [0x1D, 0x28, 0x6B, 0x04, 0x00, 0x31, 0x41, 0x32, 0x00];
    bytes += [0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x43, 0x06];
    bytes += [0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x44, 0x31];
    bytes += [
      0x1D,
      0x28,
      0x6B,
      lenByte1.toInt(),
      lenByte2.toInt(),
      0x31,
      0x50,
      0x30,
    ];
    bytes += data.codeUnits;
    bytes += [0x1D, 0x28, 0x6B, 0x03, 0x00, 0x31, 0x51, 0x30];

    return bytes;
  }

  /// Fungsi Utama untuk Generate Teks Cetak ESC/POS
  static List<int> generateParkingReceiptBytes({
    required ParkingTransaction transaction,
    required Outlet outlet,
  }) {
    List<int> bytes = [];

    final List<int> clearStyle = [0x1B, 0x21, 0x00];
    final List<int> boldStyle = [0x1B, 0x21, 0x08];
    final List<int> centerAlign = [0x1B, 0x61, 0x01];
    final List<int> leftAlign = [0x1B, 0x61, 0x00];

    final bool isActive = transaction.status.trim().toUpperCase() == 'IN';

    // --- HEADER OUTLET ---
    bytes += centerAlign + boldStyle;
    bytes += "${outlet.name.isEmpty ? "PARKIR" : outlet.name}\n".codeUnits;
    bytes += clearStyle + centerAlign;
    if (outlet.address.isNotEmpty) bytes += "${outlet.address}\n".codeUnits;
    if (outlet.phone.isNotEmpty) bytes += "Telp. ${outlet.phone}\n".codeUnits;

    bytes += "--------------------------------\n".codeUnits;

    if (isActive) {
      // --- TIKET MASUK ---
      bytes += centerAlign + boldStyle;
      bytes += "TIKET MASUK\n\n".codeUnits;
      bytes += clearStyle + leftAlign;

      bytes += "No Tiket : ${transaction.ticketNumber}\n".codeUnits;
      bytes += "No Polisi: ${transaction.plateNumber}\n".codeUnits;
      bytes +=
          "Masuk    : ${DateTimeUtil.dateTimeSlash(transaction.entryTime)}\n\n"
              .codeUnits;

      // CETAK QR CODE
      bytes += centerAlign;
      bytes += _getQrByteCommand(transaction.ticketNumber);
      bytes += "\n".codeUnits;

      bytes += centerAlign + boldStyle;
      bytes += "Scan QR Code saat keluar\n".codeUnits;
    } else {
      // --- NOTA KELUAR / PEMBAYARAN ---
      bytes += centerAlign + boldStyle;
      bytes += "NOTA PEMBAYARAN\n\n".codeUnits;
      bytes += clearStyle + leftAlign;

      bytes += "No Tiket : ${transaction.ticketNumber}\n".codeUnits;
      bytes += "No Polisi: ${transaction.plateNumber}\n".codeUnits;
      bytes +=
          "Masuk    : ${DateTimeUtil.dateTimeSlash(transaction.entryTime)}\n"
              .codeUnits;
      bytes +=
          "Keluar   : ${DateTimeUtil.dateTimeSlash(transaction.exitTime!)}\n"
              .codeUnits;
      bytes +=
          "Durasi   : ${_formatDuration(transaction.entryTime, exitTime: transaction.exitTime)}\n"
              .codeUnits;

      bytes += "--------------------------------\n".codeUnits;
      bytes += boldStyle;

      String totalLabel = "TOTAL";
      String totalFee = CurrencyUtil.format(transaction.totalFee);
      int spacesCount = 32 - totalLabel.length - totalFee.length;
      String spaces = spacesCount > 0 ? " " * spacesCount : " ";
      bytes += "$totalLabel$spaces$totalFee\n".codeUnits;
    }

    // --- FOOTER ---
    bytes += "\n".codeUnits + clearStyle + centerAlign;
    bytes += "Terima kasih\n".codeUnits;
    if (!isActive) bytes += "Selamat Jalan\n".codeUnits;

    bytes += [0x1D, 0x56, 0x41, 0x10]; // Potong kertas

    return bytes;
  }

  /// Fungsi untuk meminta izin sistem (Bluetooth & Lokasi)
  static Future<bool> requestPermissions() async {
    PermissionStatus connectStatus = await Permission.bluetoothConnect
        .request();
    PermissionStatus scanStatus = await Permission.bluetoothScan.request();
    PermissionStatus locationStatus = await Permission.location.request();

    return connectStatus.isGranted &&
        scanStatus.isGranted &&
        locationStatus.isGranted;
  }

  static Future<String?> getSavedPrinterAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastPrinterAddressKey);
  }

  static Future<void> forgetSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastPrinterAddressKey);
  }

  /// Fungsi Inti untuk mengirim byte data ke printer thermal
  static Future<void> printReceipt({
    required BuildContext context,
    required List<int> bytes,
    bool forcePickDevice = false,
  }) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // 1. Cek Izin Runtime
      bool hasPermission = await requestPermissions();
      if (!hasPermission) {
        throw FormatException(
          "Aplikasi membutuhkan izin Bluetooth & Lokasi untuk mencetak nota.",
        );
      }

      // 2. Cek apakah Bluetooth fisik di HP aktif
      bool isBluetoothOn = await PrintBluetoothThermal.bluetoothEnabled;
      if (!isBluetoothOn) {
        throw FormatException(
          "Bluetooth Anda mati. Silakan aktifkan Bluetooth HP terlebih dahulu.",
        );
      }

      String? address = forcePickDevice ? null : await getSavedPrinterAddress();
      bool connectSuccess = false;

      // 3. Coba hubungkan ke printer terakhir jika ada
      if (address != null) {
        bool isConnected = await PrintBluetoothThermal.connectionStatus;
        if (isConnected) {
          connectSuccess = true;
        } else {
          connectSuccess = await PrintBluetoothThermal.connect(
            macPrinterAddress: address,
          );
        }
      }

      // 4. JIKA PRINTER TERAKHIR TIDAK AKTIF / GAGAL KONEKSI / BELUM ADA PRINTER
      if (!connectSuccess) {
        final List<BluetoothInfo> pairedDevices =
            await PrintBluetoothThermal.pairedBluetooths;

        if (pairedDevices.isEmpty) {
          throw FormatException(
            "Tidak ada printer Bluetooth yang terikat (paired). Silakan sandingkan di pengaturan HP terlebih dahulu.",
          );
        }

        // PERBAIKAN WARNING CONTEXT: Cek mounted sebelum memanggil Dialog
        if (!context.mounted) return;

        BluetoothInfo? selectedDevice = await showDialog<BluetoothInfo>(
          context: context,
          barrierDismissible: true,
          builder: (context) => AlertDialog(
            title: const Text("Pilih Printer"),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: pairedDevices.length,
                itemBuilder: (context, index) {
                  final device = pairedDevices[index];
                  return ListTile(
                    title: Text(
                      device.name.isEmpty ? "Printer Tanpa Nama" : device.name,
                    ),
                    subtitle: Text(device.macAdress),
                    onTap: () => Navigator.pop(context, device),
                  );
                },
              ),
            ),
          ),
        );

        if (selectedDevice == null) return; // User membatalkan dialog
        address = selectedDevice.macAdress;

        bool connectNew = await PrintBluetoothThermal.connect(
          macPrinterAddress: address,
        );
        if (!connectNew) {
          throw FormatException(
            "Gagal terhubung ke printer baru. Pastikan printer menyala.",
          );
        }
      }

      // 5. Kirim data byte jika koneksi berhasil
      final success = await PrintBluetoothThermal.writeBytes(bytes);

      // PERBAIKAN WARNING CONTEXT: Cek mounted sebelum memanggil SnackBar & SharedPreferences
      if (!context.mounted) return;

      if (success) {
        // PERBAIKAN ERROR ADDRESS: Pastikan address di-cast menjadi string non-nullable aman (!)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_lastPrinterAddressKey, address!);

        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Nota berhasil dicetak!')),
        );
      } else {
        await forgetSavedPrinter();
        throw FormatException(
          'Gagal mentransfer data ke printer. Coba ulangi kembali.',
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      final errorMessage = e is FormatException ? e.message : e.toString();
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(errorMessage)));
      rethrow;
    }
  }
}
