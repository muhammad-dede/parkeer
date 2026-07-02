import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:parkeer/core/constants/app_colors.dart';
import 'package:parkeer/core/services/backup_restore_service.dart';

class BackupRestorePage extends StatefulWidget {
  const BackupRestorePage({super.key});

  @override
  State<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends State<BackupRestorePage> {
  final service = BackupRestoreService();

  bool _loadingBackup = false;
  bool _loadingRestore = false;

  Future<void> doBackup() async {
    setState(() => _loadingBackup = true);

    try {
      final file = await service.backup();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Backup berhasil\n${file.path}")));
    } catch (e) {
      if (!mounted) return;

      // Kasus dibatalkan user bukan error sungguhan
      if (e.toString().contains('dibatalkan')) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Backup dibatalkan")));
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Backup gagal: $e")));
    } finally {
      if (mounted) {
        setState(() => _loadingBackup = false);
      }
    }
  }

  Future<void> doRestore() async {
    const typeGroup = XTypeGroup(label: 'SQLite Database', extensions: ['db']);

    final selectedFile = await openFile(acceptedTypeGroups: [typeGroup]);

    if (selectedFile == null) return;

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Restore Database'),
          content: const Text(
            'Semua data saat ini akan diganti dengan data dari file backup.\n\nLanjutkan?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Restore'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _loadingRestore = true);

    try {
      await service.restore(File(selectedFile.path));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restore database berhasil.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Restore gagal: $e')));
    } finally {
      if (mounted) {
        setState(() => _loadingRestore = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _loadingBackup || _loadingRestore;
    return PopScope(
      canPop: !isBusy,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && isBusy) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tunggu proses selesai sebelum keluar.'),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Backup & Restore")),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Backup Database",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: isBusy ? null : doBackup,
                  child: _loadingBackup
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Backup Sekarang",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Restore Database",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: isBusy ? null : doRestore,
                  child: _loadingRestore
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Pilih File Backup"),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Pastikan Anda memilih file backup (.db). Setelah proses restore selesai, tutup dan buka kembali aplikasi agar database dimuat ulang.",
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
