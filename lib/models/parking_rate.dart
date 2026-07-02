class ParkingRate {
  final int? id;
  final String name;
  final String vehicleTypeCode;
  final String calculationType;
  final double minimumCharge;
  final double? maximumDailyCharge;
  final bool isActive;

  const ParkingRate({
    this.id,
    required this.name,
    required this.vehicleTypeCode,
    required this.calculationType,
    required this.minimumCharge,
    this.maximumDailyCharge,
    required this.isActive,
  });

  factory ParkingRate.fromMap(Map<String, dynamic> map) {
    return ParkingRate(
      id: map['id'] as int?,
      name: map['name'] as String,
      vehicleTypeCode: map['vehicle_type_code'] as String,
      calculationType: map['calculation_type'] as String,
      minimumCharge: (map['minimum_charge'] as num).toDouble(),
      maximumDailyCharge: map['maximum_daily_charge'] == null
          ? null
          : (map['maximum_daily_charge'] as num).toDouble(),
      isActive: map['is_active'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'vehicle_type_code': vehicleTypeCode,
      'calculation_type': calculationType,
      'minimum_charge': minimumCharge,
      'maximum_daily_charge': maximumDailyCharge,
      'is_active': isActive ? 1 : 0,
    };
  }

  ParkingRate copyWith({
    int? id,
    String? name,
    String? vehicleTypeCode,
    String? calculationType,
    double? minimumCharge,
    double? maximumDailyCharge,
    bool? isActive,
  }) {
    return ParkingRate(
      id: id ?? this.id,
      name: name ?? this.name,
      vehicleTypeCode: vehicleTypeCode ?? this.vehicleTypeCode,
      calculationType: calculationType ?? this.calculationType,
      minimumCharge: minimumCharge ?? this.minimumCharge,
      maximumDailyCharge: maximumDailyCharge ?? this.maximumDailyCharge,
      isActive: isActive ?? this.isActive,
    );
  }
}
