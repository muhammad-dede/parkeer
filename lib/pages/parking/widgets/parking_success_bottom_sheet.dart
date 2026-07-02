import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkeer/core/constants/app_colors.dart';

class ParkingSuccessBottomSheet extends StatelessWidget {
  const ParkingSuccessBottomSheet({
    super.key,
    required this.transactionId,
    required this.ticketNumber,
    required this.plateNumber,
    required this.entryTime,
    required this.onPrintNota,
    required this.onViewDetail,
    required this.onBackToList,
  });

  final int transactionId;
  final String ticketNumber;
  final String plateNumber;
  final DateTime entryTime;

  final VoidCallback onPrintNota;
  final VoidCallback onViewDetail;
  final VoidCallback onBackToList;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              children: [
                /// Isi berada di tengah layar
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
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
                            plateNumber,
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
                                  _row("No. Tiket", ticketNumber),

                                  const Divider(height: 28),

                                  _row(
                                    "Waktu Masuk",
                                    DateFormat(
                                      "dd MMM yyyy HH:mm",
                                      "id_ID",
                                    ).format(entryTime),
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

                /// Tombol selalu di bawah
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        onPressed: onViewDetail,
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
                      child: OutlinedButton(
                        onPressed: onPrintNota,
                        child: const Text("Cetak Nota"),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: onBackToList,
                        child: const Text("Tutup"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
