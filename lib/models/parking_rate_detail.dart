class ParkingRateDetail {
  final int? id;
  final int parkingRateId;
  final int fromMinute;
  final int? toMinute;
  final double price;

  const ParkingRateDetail({
    this.id,
    required this.parkingRateId,
    required this.fromMinute,
    this.toMinute,
    required this.price,
  });

  factory ParkingRateDetail.fromMap(Map<String, dynamic> map) {
    return ParkingRateDetail(
      id: map['id'] as int?,
      parkingRateId: map['parking_rate_id'] as int,
      fromMinute: map['from_minute'] as int,
      toMinute: map['to_minute'] as int?,
      price: (map['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parking_rate_id': parkingRateId,
      'from_minute': fromMinute,
      'to_minute': toMinute,
      'price': price,
    };
  }

  ParkingRateDetail copyWith({
    int? id,
    int? parkingRateId,
    int? fromMinute,
    int? toMinute,
    double? price,
  }) {
    return ParkingRateDetail(
      id: id ?? this.id,
      parkingRateId: parkingRateId ?? this.parkingRateId,
      fromMinute: fromMinute ?? this.fromMinute,
      toMinute: toMinute ?? this.toMinute,
      price: price ?? this.price,
    );
  }
}
