class ParkingTransactionDetail {
  final int? id;
  final int parkingTransactionId;
  final int fromMinute;
  final int? toMinute;
  final double price;

  const ParkingTransactionDetail({
    this.id,
    required this.parkingTransactionId,
    required this.fromMinute,
    this.toMinute,
    required this.price,
  });

  factory ParkingTransactionDetail.fromMap(Map<String, dynamic> map) {
    return ParkingTransactionDetail(
      id: map['id'] as int?,
      parkingTransactionId: map['parking_transaction_id'] as int,
      fromMinute: map['from_minute'] as int,
      toMinute: map['to_minute'] as int?,
      price: (map['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parking_transaction_id': parkingTransactionId,
      'from_minute': fromMinute,
      'to_minute': toMinute,
      'price': price,
    };
  }

  ParkingTransactionDetail copyWith({
    int? id,
    int? parkingTransactionId,
    int? fromMinute,
    int? toMinute,
    double? price,
  }) {
    return ParkingTransactionDetail(
      id: id ?? this.id,
      parkingTransactionId: parkingTransactionId ?? this.parkingTransactionId,
      fromMinute: fromMinute ?? this.fromMinute,
      toMinute: toMinute ?? this.toMinute,
      price: price ?? this.price,
    );
  }
}
