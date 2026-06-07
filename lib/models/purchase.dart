class Purchase {
  final int id;
  final int userId;
  final int resourceId;
  final String resourceName;
  final String resourceType;
  final int quantity;
  final double totalPrice;
  final double resourcePrice;
  final String resourceImage;
  final DateTime purchaseDate;

  Purchase({
    required this.id,
    required this.userId,
    required this.resourceId,
    required this.resourceName,
    required this.resourceType,
    required this.quantity,
    required this.totalPrice,
    required this.resourcePrice,
    required this.resourceImage,
    required this.purchaseDate,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      resourceId: json['resource_id'] ?? 0,
      resourceName: json['name'] ?? '',
      resourceType: json['type'] ?? '',
      quantity: json['quantity'] ?? 0,
      totalPrice: double.tryParse(json['total_price']?.toString() ?? '') ?? 0.0,
      resourcePrice: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      resourceImage: json['image_url'] ?? 'https://via.placeholder.com/200',
      purchaseDate: json['purchase_date'] != null
          ? DateTime.parse(json['purchase_date'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'resource_id': resourceId,
      'name': resourceName,
      'type': resourceType,
      'quantity': quantity,
      'total_price': totalPrice,
      'price': resourcePrice,
      'image_url': resourceImage,
      'purchase_date': purchaseDate.toIso8601String(),
    };
  }
}
