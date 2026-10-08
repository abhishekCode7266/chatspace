class PaymentTransactionModel {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final double amount;
  final String currency;
  final String note;
  final DateTime timestamp;
  final String status; // 'SUCCESS', 'PENDING', 'FAILED'
  final String upiRefId;
  final String bankName;
  final String paymentMethod; // 'UPI', 'Bank Account', 'Paytm Wallet'
  final String category; // 'UPI', 'RECHARGE', 'ELECTRICITY', 'FASTAG', 'METRO', 'DTH', 'CREDIT_CARD', 'LOAN', 'TICKETS'
  final String details;

  PaymentTransactionModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.amount,
    this.currency = '₹',
    this.note = '',
    required this.timestamp,
    this.status = 'SUCCESS',
    required this.upiRefId,
    this.bankName = 'State Bank of India',
    this.paymentMethod = 'UPI',
    this.category = 'UPI',
    this.details = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'amount': amount,
      'currency': currency,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'upiRefId': upiRefId,
      'bankName': bankName,
      'paymentMethod': paymentMethod,
      'category': category,
      'details': details,
    };
  }

  factory PaymentTransactionModel.fromMap(Map<String, dynamic> map) {
    return PaymentTransactionModel(
      id: map['id'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      senderName: map['senderName'] as String? ?? 'Sender',
      receiverId: map['receiverId'] as String? ?? '',
      receiverName: map['receiverName'] as String? ?? 'Receiver',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? '₹',
      note: map['note'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      status: map['status'] as String? ?? 'SUCCESS',
      upiRefId: map['upiRefId'] as String? ?? 'UPI${DateTime.now().millisecondsSinceEpoch}',
      bankName: map['bankName'] as String? ?? 'State Bank of India',
      paymentMethod: map['paymentMethod'] as String? ?? 'UPI',
      category: map['category'] as String? ?? 'UPI',
      details: map['details'] as String? ?? '',
    );
  }
}

class BankAccountModel {
  final String id;
  final String bankName;
  final String accountNumberMasked;
  final String ifsc;
  final String accountType; // 'Savings', 'Current'
  final bool isPrimary;
  final String upiId;
  final double balance;
  final int brandColorHex;

  final bool isInternational;
  final String country;

  String get bankId => id;

  BankAccountModel({
    required this.id,
    required this.bankName,
    required this.accountNumberMasked,
    required this.ifsc,
    this.accountType = 'Savings',
    this.isPrimary = false,
    required this.upiId,
    this.balance = 25480.50,
    this.brandColorHex = 0xFF1A5276,
    this.isInternational = false,
    this.country = 'India',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bankName': bankName,
      'accountNumberMasked': accountNumberMasked,
      'ifsc': ifsc,
      'accountType': accountType,
      'isPrimary': isPrimary,
      'upiId': upiId,
      'balance': balance,
      'brandColorHex': brandColorHex,
      'isInternational': isInternational,
      'country': country,
    };
  }

  factory BankAccountModel.fromMap(Map<String, dynamic> map) {
    return BankAccountModel(
      id: map['id'] as String? ?? '',
      bankName: map['bankName'] as String? ?? 'Bank',
      accountNumberMasked: map['accountNumberMasked'] as String? ?? '•••• 0000',
      ifsc: map['ifsc'] as String? ?? 'SBIN0001234',
      accountType: map['accountType'] as String? ?? 'Savings',
      isPrimary: map['isPrimary'] as bool? ?? false,
      upiId: map['upiId'] as String? ?? 'user@universalpay',
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      brandColorHex: map['brandColorHex'] as int? ?? 0xFF1A5276,
      isInternational: map['isInternational'] as bool? ?? false,
      country: map['country'] as String? ?? 'India',
    );
  }
}

class SubscriptionPlanModel {
  final String id;
  final String name;
  final String tagline;
  final double priceMonthly;
  final double priceYearly;
  final int cloudStorageGb;
  final int aiDailyLimit; // -1 for unlimited
  final bool hasUnlimitedAi;
  final bool hasImageGeneration;
  final bool hasVerifiedBadge;
  final bool hasPrioritySupport;
  final bool isAdFree;
  final bool isPopular;
  final List<String> keyFeatures;

  const SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.tagline,
    required this.priceMonthly,
    required this.priceYearly,
    required this.cloudStorageGb,
    required this.aiDailyLimit,
    this.hasUnlimitedAi = false,
    this.hasImageGeneration = true,
    this.hasVerifiedBadge = false,
    this.hasPrioritySupport = false,
    this.isAdFree = false,
    this.isPopular = false,
    required this.keyFeatures,
  });
}
