class Resource {
  final int id;
  final String name;
  final String type;
  final String description;
  final int stock;
  final String imageUrl;
  final double price;
  final DateTime createdAt;

  Resource({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.stock,
    required this.imageUrl,
    required this.price,
    required this.createdAt,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      stock: json['stock'] ?? 0,
      imageUrl: json['image_url'] ?? 'https://via.placeholder.com/200',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'stock': stock,
      'image_url': imageUrl,
      'price': price,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isAvailable => stock > 0;
}
