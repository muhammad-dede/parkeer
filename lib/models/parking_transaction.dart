class ParkingTransaction {
  final int? id;
  final String ticketNumber;
  final String plateNumber;
  final String vehicleTypeCode;
  final DateTime entryTime;
  final DateTime? exitTime;
  final double minimumCharge;
  final double? maximumDailyCharge;
  final double totalFee;
  final String status;

  const ParkingTransaction({
    this.id,
    required this.ticketNumber,
    required this.plateNumber,
    required this.vehicleTypeCode,
    required this.entryTime,
    this.exitTime,
    required this.minimumCharge,
    this.maximumDailyCharge,
    required this.totalFee,
    required this.status,
  });

  factory ParkingTransaction.fromMap(Map<String, dynamic> map) {
    return ParkingTransaction(
      id: map['id'] as int?,
      ticketNumber: map['ticket_number'] as String,
      plateNumber: map['plate_number'] as String,
      vehicleTypeCode: map['vehicle_type_code'] as String,
      entryTime: DateTime.parse(map['entry_time']),
      exitTime: map['exit_time'] == null
          ? null
          : DateTime.parse(map['exit_time']),
      minimumCharge: (map['minimum_charge'] as num).toDouble(),
      maximumDailyCharge: map['maximum_daily_charge'] == null
          ? null
          : (map['maximum_daily_charge'] as num).toDouble(),
      totalFee: (map['total_fee'] as num).toDouble(),
      status: map['status'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ticket_number': ticketNumber,
      'plate_number': plateNumber,
      'vehicle_type_code': vehicleTypeCode,
      'entry_time': entryTime.toIso8601String(),
      'exit_time': exitTime?.toIso8601String(),
      'minimum_charge': minimumCharge,
      'maximum_daily_charge': maximumDailyCharge,
      'total_fee': totalFee,
      'status': status,
    };
  }

  ParkingTransaction copyWith({
    int? id,
    String? ticketNumber,
    String? plateNumber,
    String? vehicleTypeCode,
    DateTime? entryTime,
    DateTime? exitTime,
    double? minimumCharge,
    double? maximumDailyCharge,
    double? totalFee,
    String? status,
  }) {
    return ParkingTransaction(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      plateNumber: plateNumber ?? this.plateNumber,
      vehicleTypeCode: vehicleTypeCode ?? this.vehicleTypeCode,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
      minimumCharge: minimumCharge ?? this.minimumCharge,
      maximumDailyCharge: maximumDailyCharge ?? this.maximumDailyCharge,
      totalFee: totalFee ?? this.totalFee,
      status: status ?? this.status,
    );
  }
}
