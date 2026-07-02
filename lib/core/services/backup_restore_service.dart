import 'dart:io';

import 'package:parkeer/core/database/database_helper.dart';
import 'package:parkeer/core/utils/date_time_util.dart';
import 'package:share_plus/share_plus.dart';

class BackupRestoreService {
  final _dbHelper = DatabaseHelper.instance;

  /// Backup database dan buka share sheet supaya user bisa
  /// menyimpan/mengirim filenya (Google Drive, WhatsApp, dll).
  Future<File> backup() async {
    final dbPath = await _dbHelper.getDatabasePath();
    final sourceFile = File(dbPath);

    if (!await sourceFile.exists()) {
      throw Exception('Database tidak ditemukan.');
    }

    // Tutup koneksi supaya semua data ter-flush ke disk sebelum disalin.
    await _dbHelper.close();

    try {
      final timestamp = DateTimeUtil.timestamp(DateTime.now());
      final backupName = 'parkeer_backup_$timestamp.db';

      // Salin ke file terpisah dengan nama rapi (jangan share file DB asli
      // yang sedang aktif dipakai app).
      final tempCopy = File('${sourceFile.parent.path}/$backupName');
      await sourceFile.copy(tempCopy.path);

      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(tempCopy.path)],
          subject: 'Backup Database Parkeer',
        ),
      );

      if (result.status == ShareResultStatus.dismissed) {
        throw Exception('Backup dibatalkan.');
      }

      return tempCopy;
    } finally {
      // Pastikan database selalu dibuka kembali, apapun hasilnya.
      await _dbHelper.initialize();
    }
  }

  /// Restore database dari file backup yang dipilih user.
  Future<void> restore(File backupFile) async {
    if (!await backupFile.exists()) {
      throw Exception('File backup tidak ditemukan.');
    }

    if (!await _isValidSqliteFile(backupFile)) {
      throw Exception('File yang dipilih bukan database SQLite yang valid.');
    }

    final dbPath = await _dbHelper.getDatabasePath();

    // Tutup koneksi lama sebelum file database ditimpa.
    await _dbHelper.close();

    try {
      await backupFile.copy(dbPath);
    } finally {
      // Buka kembali database (baik berhasil maupun gagal copy).
      await _dbHelper.initialize();
    }
  }

  /// Cek cepat apakah file benar-benar file SQLite (baca magic header).
  Future<bool> _isValidSqliteFile(File file) async {
    try {
      final raf = await file.open();
      final header = await raf.read(16);
      await raf.close();

      const magic = 'SQLite format 3';
      if (header.length < magic.length) return false;

      final headerText = String.fromCharCodes(header.sublist(0, magic.length));
      return headerText == magic;
    } catch (_) {
      return false;
    }
  }
}
