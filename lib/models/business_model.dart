class ProductModel {
  final String id;
  final String name;
  final double price;
  final String currency;
  final String description;
  final String imageUrl;
  final bool inStock;
  final String category;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.currency = '₹',
    required this.description,
    required this.imageUrl,
    this.inStock = true,
    this.category = 'General',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'currency': currency,
      'description': description,
      'imageUrl': imageUrl,
      'inStock': inStock,
      'category': category,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? '₹',
      description: map['description'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      inStock: map['inStock'] as bool? ?? true,
      category: map['category'] as String? ?? 'General',
    );
  }
}

class BusinessProfileModel {
  final String businessId;
  final String businessName;
  final String category;
  final String description;
  final String email;
  final String website;
  final String address;
  final String workingHours;
  final bool isVerified;
  final String autoGreetingMessage;
  final String autoAwayMessage;
  final bool autoReplyEnabled;

  BusinessProfileModel({
    required this.businessId,
    required this.businessName,
    required this.category,
    required this.description,
    required this.email,
    required this.website,
    required this.address,
    required this.workingHours,
    this.isVerified = true,
    this.autoGreetingMessage = 'Welcome to our official business chat! How can we assist you today?',
    this.autoAwayMessage = 'We are currently away. Our team will get back to you shortly.',
    this.autoReplyEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'businessId': businessId,
      'businessName': businessName,
      'category': category,
      'description': description,
      'email': email,
      'website': website,
      'address': address,
      'workingHours': workingHours,
      'isVerified': isVerified,
      'autoGreetingMessage': autoGreetingMessage,
      'autoAwayMessage': autoAwayMessage,
      'autoReplyEnabled': autoReplyEnabled,
    };
  }

  factory BusinessProfileModel.fromMap(Map<String, dynamic> map) {
    return BusinessProfileModel(
      businessId: map['businessId'] as String? ?? '',
      businessName: map['businessName'] as String? ?? 'Universal Enterprise',
      category: map['category'] as String? ?? 'Technology & Software',
      description: map['description'] as String? ?? 'Leading innovative AI & communication solutions.',
      email: map['email'] as String? ?? 'support@universalchat.app',
      website: map['website'] as String? ?? 'https://universalchat.app',
      address: map['address'] as String? ?? 'Tech Hub, Silicon Heights, New Delhi',
      workingHours: map['workingHours'] as String? ?? 'Mon - Sat: 9:00 AM - 8:00 PM',
      isVerified: map['isVerified'] as bool? ?? true,
      autoGreetingMessage: map['autoGreetingMessage'] as String? ??
          'Welcome to our official business chat! How can we assist you today?',
      autoAwayMessage: map['autoAwayMessage'] as String? ??
          'We are currently away. Our team will get back to you shortly.',
      autoReplyEnabled: map['autoReplyEnabled'] as bool? ?? true,
    );
  }
}

class OrderModel {
  final String orderId;
  final String customerName;
  final String productName;
  final double amount;
  final String status; // 'Pending', 'Processing', 'Delivered', 'Cancelled'
  final DateTime timestamp;

  OrderModel({
    required this.orderId,
    required this.customerName,
    required this.productName,
    required this.amount,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'customerName': customerName,
      'productName': productName,
      'amount': amount,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['orderId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? 'Customer',
      productName: map['productName'] as String? ?? 'Product',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'Pending',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
