class Category {
  final String name;

  Category({
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}