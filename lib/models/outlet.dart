class Outlet {
  final String name;
  final String address;
  final String phone;
  final String email;

  Outlet({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
  });

  factory Outlet.empty() {
    return Outlet(name: '', address: '', phone: '', email: '');
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'address': address, 'phone': phone, 'email': email};
  }

  factory Outlet.fromJson(Map<String, dynamic> json) {
    return Outlet(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
