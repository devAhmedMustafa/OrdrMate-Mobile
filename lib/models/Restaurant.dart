class Restaurant {
  final String id;
  final String name;
  final String email;
  final String phone;

  Restaurant({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}