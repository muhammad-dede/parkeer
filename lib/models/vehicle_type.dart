class VehicleType {
  final int? id;
  final String code;
  final String name;

  const VehicleType({this.id, required this.code, required this.name});

  factory VehicleType.fromMap(Map<String, dynamic> map) {
    return VehicleType(
      id: map['id'] as int?,
      code: map['code'] as String,
      name: map['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'code': code, 'name': name};
  }

  VehicleType copyWith({int? id, String? code, String? name}) {
    return VehicleType(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
    );
  }

  @override
  String toString() => 'VehicleType(id: $id, code: $code, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleType &&
          id == other.id &&
          code == other.code &&
          name == other.name;

  @override
  int get hashCode => Object.hash(id, code, name);
}
