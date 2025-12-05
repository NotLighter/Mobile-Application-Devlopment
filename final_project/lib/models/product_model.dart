import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String sellerId;
  final String sellerName;
  final String sellerProfilePicture;
  final String title;
  final String description;
  final String category;
  final double price;
  final double? discountPrice;
  final List<String> images;
  final String condition;
  final int quantity;
  final bool isAvailable;
  final bool isFeatured;
  final String location;
  final List<String> tags;
  int views;
  int favorites;
  bool isFavorited;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    this.sellerProfilePicture = '',
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    this.discountPrice,
    this.images = const [],
    this.condition = 'New',
    this.quantity = 1,
    this.isAvailable = true,
    this.isFeatured = false,
    this.location = '',
    this.tags = const [],
    this.views = 0,
    this.favorites = 0,
    this.isFavorited = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // ==================== FROM MAP (Firestore → Dart) ====================
  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      sellerProfilePicture: map['sellerProfilePicture'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      discountPrice: map['discountPrice']?.toDouble(),
      images: List<String>.from(map['images'] ?? []),
      condition: map['condition'] ?? 'New',
      quantity: map['quantity']?.toInt() ?? 1,
      isAvailable: map['isAvailable'] ?? true,
      isFeatured: map['isFeatured'] ?? false,
      location: map['location'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      views: map['views']?.toInt() ?? 0,
      favorites: map['favorites']?.toInt() ?? 0,
      isFavorited: map['isFavorited'] ?? false,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  // ==================== TO MAP (Dart → Firestore) ====================
  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerProfilePicture': sellerProfilePicture,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'discountPrice': discountPrice,
      'images': images,
      'condition': condition,
      'quantity': quantity,
      'isAvailable': isAvailable,
      'isFeatured': isFeatured,
      'location': location,
      'tags': tags,
      'views': views,
      'favorites': favorites,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // ==================== COPY WITH ====================
  ProductModel copyWith({
    String? id,
    String? sellerId,
    String? sellerName,
    String? sellerProfilePicture,
    String? title,
    String? description,
    String? category,
    double? price,
    double? discountPrice,
    List<String>? images,
    String? condition,
    int? quantity,
    bool? isAvailable,
    bool? isFeatured,
    String? location,
    List<String>? tags,
    int? views,
    int? favorites,
    bool? isFavorited,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerProfilePicture: sellerProfilePicture ?? this.sellerProfilePicture,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      images: images ?? this.images,
      condition: condition ?? this.condition,
      quantity: quantity ?? this.quantity,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      views: views ?? this.views,
      favorites: favorites ?? this.favorites,
      isFavorited: isFavorited ?? this.isFavorited,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ==================== HELPER METHOD ====================
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  // ==================== FORMATTED PRICE ====================
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String? get formattedDiscountPrice =>
      discountPrice != null ? '\$${discountPrice!.toStringAsFixed(2)}' : null;

  double? get discountPercentage {
    if (discountPrice != null && discountPrice! < price) {
      return ((price - discountPrice!) / price * 100);
    }
    return null;
  }

  // ==================== TIME AGO ====================
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, title: $title, price: $price)';
  }
}