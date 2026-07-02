import 'package:parkeer/core/database/database_helper.dart';
import 'package:parkeer/models/parking_rate.dart';
import 'package:parkeer/models/parking_rate_detail.dart';

class ParkingRateRepository {
  ParkingRateRepository._();

  static final ParkingRateRepository instance = ParkingRateRepository._();

  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<(ParkingRate, List<ParkingRateDetail>)?> get() async {
    final db = await _databaseHelper.database;

    final rateResult = await db.query('parking_rates', limit: 1);

    if (rateResult.isEmpty) {
      return null;
    }

    final rate = ParkingRate.fromMap(rateResult.first);

    final detailResult = await db.query(
      'parking_rate_details',
      where: 'parking_rate_id = ?',
      whereArgs: [rate.id],
      orderBy: 'from_minute ASC',
    );

    final details = detailResult.map(ParkingRateDetail.fromMap).toList();

    return (rate, details);
  }

  Future<void> update(ParkingRate rate, List<ParkingRateDetail> details) async {
    final db = await _databaseHelper.database;

    await db.transaction((txn) async {
      await txn.update(
        'parking_rates',
        rate.toMap(),
        where: 'id = ?',
        whereArgs: [rate.id],
      );

      await txn.delete(
        'parking_rate_details',
        where: 'parking_rate_id = ?',
        whereArgs: [rate.id],
      );

      for (final detail in details) {
        await txn.insert('parking_rate_details', {
          ...detail.toMap(),
          'id': null,
          'parking_rate_id': rate.id,
        });
      }
    });
  }
}
