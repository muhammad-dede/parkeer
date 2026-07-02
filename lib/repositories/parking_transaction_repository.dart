import 'package:intl/intl.dart';
import 'package:parkeer/core/database/database_helper.dart';
import 'package:parkeer/core/events/app_event_bus.dart';
import 'package:parkeer/core/events/transaction_changed_event.dart';
import 'package:parkeer/models/dashboard_summary.dart';
import 'package:parkeer/models/parking_rate.dart';
import 'package:parkeer/models/parking_rate_detail.dart';
import 'package:parkeer/models/parking_transaction.dart';
import 'package:parkeer/models/parking_transaction_detail.dart';

class ParkingTransactionRepository {
  ParkingTransactionRepository._();

  static final ParkingTransactionRepository instance =
      ParkingTransactionRepository._();

  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<ParkingRate?> getActiveRate(String vehicleTypeCode) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'parking_rates',
      where: 'vehicle_type_code = ? AND is_active = ?',
      whereArgs: [vehicleTypeCode, 1],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return ParkingRate.fromMap(result.first);
  }

  Future<List<ParkingRateDetail>> getRateDetails(int parkingRateId) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'parking_rate_details',
      where: 'parking_rate_id = ?',
      whereArgs: [parkingRateId],
      orderBy: 'from_minute ASC',
    );

    return result.map((e) => ParkingRateDetail.fromMap(e)).toList();
  }

  Future<int> createTransaction(ParkingTransaction transaction) async {
    final db = await _databaseHelper.database;

    final id = await db.insert('parking_transactions', transaction.toMap());

    AppEventBus.instance.fire(TransactionChangedEvent());

    return id;
  }

  Future<void> createTransactionDetails(
    List<ParkingTransactionDetail> details,
  ) async {
    final db = await _databaseHelper.database;

    final batch = db.batch();

    for (final detail in details) {
      batch.insert('parking_transaction_details', detail.toMap());
    }

    await batch.commit(noResult: true);
  }

  Future<void> completeTransaction({
    required int transactionId,
    required DateTime exitTime,
    required int totalFee,
  }) async {
    final db = await _databaseHelper.database;

    await db.update(
      'parking_transactions',
      {
        'status': 'OUT',
        'exit_time': exitTime.toIso8601String(),
        'total_fee': totalFee,
      },
      where: 'id = ?',
      whereArgs: [transactionId],
    );

    AppEventBus.instance.fire(TransactionChangedEvent());
  }

  Future<void> deleteTransaction(int transactionId) async {
    final db = await _databaseHelper.database;

    await db.transaction((txn) async {
      await txn.delete(
        'parking_transaction_details',
        where: 'parking_transaction_id = ?',
        whereArgs: [transactionId],
      );

      await txn.delete(
        'parking_transactions',
        where: 'id = ?',
        whereArgs: [transactionId],
      );
    });

    AppEventBus.instance.fire(TransactionChangedEvent());
  }

  Future<List<ParkingTransaction>> getActiveTransactions({
    String keyword = '',
    int limit = 10,
    int offset = 0,
  }) async {
    final db = await _databaseHelper.database;

    final where = StringBuffer("status = ?");
    final args = <Object?>['IN'];

    if (keyword.isNotEmpty) {
      where.write('''
      AND (
        plate_number LIKE ?
        OR ticket_number LIKE ?
      )
    ''');

      args.add('%$keyword%');
      args.add('%$keyword%');
    }

    final result = await db.query(
      'parking_transactions',
      where: where.toString(),
      whereArgs: args,
      orderBy: 'entry_time DESC',
      limit: limit,
      offset: offset,
    );

    return result.map((e) => ParkingTransaction.fromMap(e)).toList();
  }

  Future<ParkingTransaction?> getTransactionById(int id) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'parking_transactions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return ParkingTransaction.fromMap(result.first);
  }

  Future<ParkingTransaction?> getTransactionByTicketNumber(
    String ticketNumber,
  ) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'parking_transactions',
      where: 'ticket_number = ?',
      whereArgs: [ticketNumber],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return ParkingTransaction.fromMap(result.first);
  }

  Future<double> calculateParkingFee({
    required int transactionId,
    DateTime? exitTime,
  }) async {
    final db = await _databaseHelper.database;

    final transactionResult = await db.query(
      'parking_transactions',
      where: 'id = ?',
      whereArgs: [transactionId],
      limit: 1,
    );

    if (transactionResult.isEmpty) {
      return 0;
    }

    final transaction = ParkingTransaction.fromMap(transactionResult.first);

    final details = await db.query(
      'parking_transaction_details',
      where: 'parking_transaction_id = ?',
      whereArgs: [transactionId],
      orderBy: 'from_minute ASC',
    );

    if (details.isEmpty) {
      return 0;
    }

    final end = exitTime ?? DateTime.now();

    final totalMinutes = end.difference(transaction.entryTime).inMinutes;

    double total = 0;

    for (final row in details) {
      final from = row['from_minute'] as int;
      final to = row['to_minute'] as int?;
      final price = (row['price'] as num).toDouble();

      if (totalMinutes < from) {
        break;
      }

      total += price;

      if (to == null) {
        final interval = to == null
            ? (from - (details[details.length - 2]['from_minute'] as int))
            : (to - from);

        if (interval > 0) {
          final extraMinutes = totalMinutes - from;
          final extraTier = (extraMinutes / interval).floor();

          total += extraTier * price;
        }

        break;
      }
    }

    final maxDaily = transaction.maximumDailyCharge ?? 0;

    if (maxDaily > 0 && total > maxDaily) {
      total = maxDaily;
    }

    return total;
  }

  // DASHBOARD //
  Future<DashboardSummary> getDashboardSummary() async {
    final db = await _databaseHelper.database;

    final parkingResult = await db.rawQuery("""
    SELECT COUNT(*) total
    FROM parking_transactions
    WHERE status='IN'
  """);

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final vehicleTodayResult = await db.rawQuery(
      """
    SELECT COUNT(*) total
    FROM parking_transactions
    WHERE date(entry_time)=?
  """,
      [today],
    );

    final incomeTodayResult = await db.rawQuery(
      """
    SELECT IFNULL(SUM(total_fee),0) total
    FROM parking_transactions
    WHERE status='OUT'
    AND date(exit_time)=?
  """,
      [today],
    );

    final incomeWeekResult = await db.rawQuery("""
    SELECT IFNULL(SUM(total_fee),0) total
    FROM parking_transactions
    WHERE status='OUT'
    AND exit_time >= date('now','-6 day')
  """);

    final incomeMonthResult = await db.rawQuery("""
    SELECT IFNULL(SUM(total_fee),0) total
    FROM parking_transactions
    WHERE status='OUT'
    AND strftime('%Y-%m',exit_time)=strftime('%Y-%m','now')
  """);

    return DashboardSummary(
      parkingCount: parkingResult.first['total'] as int,
      vehicleInToday: vehicleTodayResult.first['total'] as int,
      incomeToday: (incomeTodayResult.first['total'] as num).toDouble(),
      incomeWeek: (incomeWeekResult.first['total'] as num).toDouble(),
      incomeMonth: (incomeMonthResult.first['total'] as num).toDouble(),
    );
  }

  // HISTORY //
  Future<Map<String, dynamic>> getHistorySummary({
    String keyword = '',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _databaseHelper.database;

    final where = StringBuffer("status = ?");
    final args = <Object?>['OUT'];

    if (keyword.isNotEmpty) {
      where.write('''
      AND (
        plate_number LIKE ?
        OR ticket_number LIKE ?
      )
    ''');

      args.add('%$keyword%');
      args.add('%$keyword%');
    }

    if (startDate != null) {
      where.write(" AND date(exit_time) >= date(?)");
      args.add(DateFormat('yyyy-MM-dd').format(startDate));
    }

    if (endDate != null) {
      where.write(" AND date(exit_time) <= date(?)");
      args.add(DateFormat('yyyy-MM-dd').format(endDate));
    }

    final result = await db.rawQuery('''
    SELECT
      COUNT(*) AS total_transaction,
      IFNULL(SUM(total_fee),0) AS total_income
    FROM parking_transactions
    WHERE ${where.toString()}
    ''', args);

    return result.first;
  }

  Future<List<ParkingTransaction>> getHistories({
    String keyword = '',
    int limit = 10,
    int offset = 0,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _databaseHelper.database;

    final where = StringBuffer("status = ?");
    final args = <Object?>['OUT'];

    if (keyword.isNotEmpty) {
      where.write('''
      AND (
        plate_number LIKE ?
        OR ticket_number LIKE ?
      )
    ''');

      args.add('%$keyword%');
      args.add('%$keyword%');
    }

    if (startDate != null) {
      where.write(" AND date(exit_time) >= date(?)");
      args.add(DateFormat('yyyy-MM-dd').format(startDate));
    }

    if (endDate != null) {
      where.write(" AND date(exit_time) <= date(?)");
      args.add(DateFormat('yyyy-MM-dd').format(endDate));
    }

    final result = await db.query(
      'parking_transactions',
      where: where.toString(),
      whereArgs: args,
      orderBy: 'exit_time DESC',
      limit: limit,
      offset: offset,
    );

    return result.map((e) => ParkingTransaction.fromMap(e)).toList();
  }
}
