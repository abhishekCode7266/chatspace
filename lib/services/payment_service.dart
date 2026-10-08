import 'dart:async';
import '../models/payment_model.dart';

/// Comprehensive Payments, Bank Accounts, UPI and Freemium Subscription Service
class PaymentService {
  static final PaymentService instance = PaymentService._internal();
  PaymentService._internal() {
    _initDefaults();
  }

  // Security UPI PIN (default is '1234' for developer and instant test drive)
  String _upiPin = '1234';
  bool _biometricPayEnabled = true;

  // Subscription & Storage state
  String _activePlanId = 'free'; // 'free', 'pro', 'business'
  int _cloudStorageUsedMb = 1840; // ~1.84 GB used

  // Freemium AI Quota
  final int _dailyFreeAiLimit = 15;
  int _aiQueriesUsedToday = 3;

  // Bank accounts
  final List<BankAccountModel> _bankAccounts = [];

  // Transactions
  final List<PaymentTransactionModel> _transactions = [];
  final StreamController<List<PaymentTransactionModel>> _txnStreamController =
      StreamController<List<PaymentTransactionModel>>.broadcast();

  // Subscription Plans
  final List<SubscriptionPlanModel> plans = const [
    SubscriptionPlanModel(
      id: 'free',
      name: 'Free Starter (मुफ्त)',
      tagline: 'Standard messaging & basic AI assistance',
      priceMonthly: 0,
      priceYearly: 0,
      cloudStorageGb: 5,
      aiDailyLimit: 15,
      hasUnlimitedAi: false,
      hasImageGeneration: true,
      hasVerifiedBadge: false,
      hasPrioritySupport: false,
      isAdFree: false,
      isPopular: false,
      keyFeatures: [
        '5GB Cloud Storage for chats & media',
        '15 Free Meta AI Queries per day',
        'HD 1-to-1 Voice & Video Calls',
        'Bank UPI In-Chat Payments',
        'Community & Group Chats',
        'Standard sponsor partner ads',
      ],
    ),
    SubscriptionPlanModel(
      id: 'pro',
      name: 'Universal Pro (प्रीमियम)',
      tagline: 'Unlimited Meta AI, 100GB Extra Cloud Storage & Ad-Free',
      priceMonthly: 199,
      priceYearly: 1999,
      cloudStorageGb: 100,
      aiDailyLimit: -1,
      hasUnlimitedAi: true,
      hasImageGeneration: true,
      hasVerifiedBadge: true,
      hasPrioritySupport: true,
      isAdFree: true,
      isPopular: true,
      keyFeatures: [
        '100GB Extra Encrypted Cloud Storage',
        'Unlimited Meta AI & /imagine image generation',
        '100% Ad-Free uninterrupted experience',
        'Verified Gold Star Badge ⭐ next to profile',
        'Large file sharing up to 2GB per document',
        'Priority 24/7 customer support',
      ],
    ),
    SubscriptionPlanModel(
      id: 'business',
      name: 'Business Enterprise (बिजनेस)',
      tagline: '1TB Cloud Storage, Team Customer Chat Bot & Commerce',
      priceMonthly: 699,
      priceYearly: 6999,
      cloudStorageGb: 1024,
      aiDailyLimit: -1,
      hasUnlimitedAi: true,
      hasImageGeneration: true,
      hasVerifiedBadge: true,
      hasPrioritySupport: true,
      isAdFree: true,
      isPopular: false,
      keyFeatures: [
        '1TB (1024GB) Secure Cloud Storage',
        'Automated AI Customer Reply Bot',
        'Product Catalog Boost & In-Chat Commerce',
        'Verified Green Business Checkmark ✅',
        'Dedicated team accounts & multi-agent seating',
        'Priority Instant UPI Payment settlement',
      ],
    ),
  ];

  void _initDefaults() {
    _bankAccounts.addAll([
      BankAccountModel(
        id: 'bank_sbi_01',
        bankName: 'State Bank of India',
        accountNumberMasked: '•••• 4821',
        ifsc: 'SBIN0001842',
        accountType: 'Savings',
        isPrimary: true,
        upiId: 'rajnesh@oksbi',
        balance: 42850.75,
        brandColorHex: 0xFF003366,
      ),
      BankAccountModel(
        id: 'bank_hdfc_02',
        bankName: 'HDFC Bank',
        accountNumberMasked: '•••• 9102',
        ifsc: 'HDFC0000492',
        accountType: 'Savings',
        isPrimary: false,
        upiId: 'rajnesh@okhdfcbank',
        balance: 18420.50,
        brandColorHex: 0xFF004B87,
      ),
      BankAccountModel(
        id: 'bank_paytm_03',
        bankName: 'Paytm Payments Bank',
        accountNumberMasked: '•••• 6350',
        ifsc: 'PYTM0123456',
        accountType: 'Current',
        isPrimary: false,
        upiId: 'rajnesh@paytm',
        balance: 6710.00,
        brandColorHex: 0xFF00B9F5,
      ),
    ]);

    _transactions.addAll([
      PaymentTransactionModel(
        id: 'txn_101',
        senderId: 'user_alice_01',
        senderName: 'Alice Johnson',
        receiverId: 'current_user',
        receiverName: 'You',
        amount: 1500.0,
        note: 'Freelance UI design review payment',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        status: 'SUCCESS',
        upiRefId: 'UPI20261008001824',
        bankName: 'State Bank of India',
      ),
      PaymentTransactionModel(
        id: 'txn_102',
        senderId: 'current_user',
        senderName: 'You',
        receiverId: 'user_bob_02',
        receiverName: 'Bob Smith',
        amount: 450.0,
        note: 'Team lunch split & coffee ☕',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        status: 'SUCCESS',
        upiRefId: 'UPI20261007094182',
        bankName: 'HDFC Bank',
      ),
      PaymentTransactionModel(
        id: 'txn_103',
        senderId: 'user_charlie_03',
        senderName: 'Charlie Dev',
        receiverId: 'current_user',
        receiverName: 'You',
        amount: 2800.0,
        note: 'Payment for API Integration sprint',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        status: 'SUCCESS',
        upiRefId: 'UPI20261006152910',
        bankName: 'State Bank of India',
      ),
    ]);
  }

  // --- Getters ---
  List<BankAccountModel> get bankAccounts => List.unmodifiable(_bankAccounts);
  List<PaymentTransactionModel> get transactions => List.unmodifiable(_transactions);
  Stream<List<PaymentTransactionModel>> get transactionStream => _txnStreamController.stream;

  String get activePlanId => _activePlanId;
  bool get isPremiumUser => _activePlanId != 'free';
  bool get isAdFree => _activePlanId != 'free';
  int get cloudStorageUsedMb => _cloudStorageUsedMb;

  int get cloudStorageLimitGb {
    final plan = plans.firstWhere((p) => p.id == _activePlanId, orElse: () => plans.first);
    return plan.cloudStorageGb;
  }

  int get dailyFreeAiLimit => _dailyFreeAiLimit;
  int get aiQueriesUsedToday => _aiQueriesUsedToday;
  int get remainingFreeAiQueries =>
      isPremiumUser ? 9999 : (_dailyFreeAiLimit - _aiQueriesUsedToday).clamp(0, _dailyFreeAiLimit);

  bool get biometricPayEnabled => _biometricPayEnabled;
  void toggleBiometricPay(bool enabled) => _biometricPayEnabled = enabled;

  // --- Security & PIN ---
  bool verifyUpiPin(String enteredPin) {
    return enteredPin == _upiPin;
  }

  void updateUpiPin(String newPin) {
    if (newPin.length == 4) {
      _upiPin = newPin;
    }
  }

  // --- AI Quota Methods ---
  bool canUseAi() {
    if (isPremiumUser) return true;
    return _aiQueriesUsedToday < _dailyFreeAiLimit;
  }

  void recordAiQuery() {
    _aiQueriesUsedToday++;
  }

  void resetDailyAiQuota() {
    _aiQueriesUsedToday = 0;
  }

  // --- Bank Operations ---
  void addBankAccount(BankAccountModel account) {
    _bankAccounts.add(account);
  }

  void setPrimaryBank(String bankId) {
    for (int i = 0; i < _bankAccounts.length; i++) {
      final b = _bankAccounts[i];
      _bankAccounts[i] = BankAccountModel(
        id: b.id,
        bankName: b.bankName,
        accountNumberMasked: b.accountNumberMasked,
        ifsc: b.ifsc,
        accountType: b.accountType,
        isPrimary: b.id == bankId,
        upiId: b.upiId,
        balance: b.balance,
        brandColorHex: b.brandColorHex,
      );
    }
  }

  BankAccountModel get primaryBank {
    return _bankAccounts.firstWhere(
      (b) => b.isPrimary,
      orElse: () => _bankAccounts.isNotEmpty
          ? _bankAccounts.first
          : BankAccountModel(
              id: 'bank_default',
              bankName: 'Universal Payments Bank',
              accountNumberMasked: '•••• 1234',
              ifsc: 'UNIV0001',
              upiId: 'user@universalpay',
            ),
    );
  }

  // --- Send Money (UPI / Bank Transfer) ---
  PaymentTransactionModel sendMoney({
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required double amount,
    required String note,
    String? bankName,
  }) {
    final usedBank = bankName ?? primaryBank.bankName;
    final txn = PaymentTransactionModel(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      receiverName: receiverName,
      amount: amount,
      currency: '₹',
      note: note,
      timestamp: DateTime.now(),
      status: 'SUCCESS',
      upiRefId: 'UPI${DateTime.now().millisecondsSinceEpoch}',
      bankName: usedBank,
      paymentMethod: 'UPI',
    );

    _transactions.insert(0, txn);
    _txnStreamController.add(List.from(_transactions));
    return txn;
  }

  // --- Request Money ---
  PaymentTransactionModel requestMoney({
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required double amount,
    required String note,
  }) {
    final txn = PaymentTransactionModel(
      id: 'txn_req_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      senderName: senderName,
      receiverId: receiverId,
      receiverName: receiverName,
      amount: amount,
      currency: '₹',
      note: note,
      timestamp: DateTime.now(),
      status: 'PENDING',
      upiRefId: 'REQ${DateTime.now().millisecondsSinceEpoch}',
      bankName: primaryBank.bankName,
      paymentMethod: 'UPI Request',
    );

    _transactions.insert(0, txn);
    _txnStreamController.add(List.from(_transactions));
    return txn;
  }

  // --- Bank Balance Helpers ---
  void _deductFromPrimaryBank(double amount) {
    final idx = _bankAccounts.indexWhere((b) => b.isPrimary);
    if (idx != -1) {
      final b = _bankAccounts[idx];
      final newBal = (b.balance - amount).clamp(0.0, 999999999.0);
      _bankAccounts[idx] = BankAccountModel(
        id: b.id,
        bankName: b.bankName,
        accountNumberMasked: b.accountNumberMasked,
        ifsc: b.ifsc,
        accountType: b.accountType,
        isPrimary: true,
        upiId: b.upiId,
        balance: newBal,
        brandColorHex: b.brandColorHex,
      );
    }
  }

  void _addToPrimaryBank(double amount) {
    final idx = _bankAccounts.indexWhere((b) => b.isPrimary);
    if (idx != -1) {
      final b = _bankAccounts[idx];
      _bankAccounts[idx] = BankAccountModel(
        id: b.id,
        bankName: b.bankName,
        accountNumberMasked: b.accountNumberMasked,
        ifsc: b.ifsc,
        accountType: b.accountType,
        isPrimary: true,
        upiId: b.upiId,
        balance: b.balance + amount,
        brandColorHex: b.brandColorHex,
      );
    }
  }

  // --- Simulate Receiving Money / Payment Received QR ---
  PaymentTransactionModel receiveMoneySimulated({
    required double amount,
    required String senderName,
    required String senderUpi,
    String note = 'Payment received via Universal Pay QR',
  }) {
    _addToPrimaryBank(amount);
    final txn = PaymentTransactionModel(
      id: 'txn_rec_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'payer_${DateTime.now().millisecondsSinceEpoch}',
      senderName: senderName,
      receiverId: 'current_user',
      receiverName: 'You',
      amount: amount,
      currency: '₹',
      note: note,
      timestamp: DateTime.now(),
      status: 'SUCCESS',
      upiRefId: 'UPI${DateTime.now().millisecondsSinceEpoch}',
      bankName: primaryBank.bankName,
      paymentMethod: 'UPI QR',
      category: 'UPI',
      details: 'Received from $senderUpi',
    );

    _transactions.insert(0, txn);
    _txnStreamController.add(List.from(_transactions));
    return txn;
  }

  // --- Pay to Mobile Number / Contact ---
  PaymentTransactionModel payToMobile({
    required String mobileNumber,
    required String contactName,
    required double amount,
    String note = '',
  }) {
    _deductFromPrimaryBank(amount);
    final txn = PaymentTransactionModel(
      id: 'txn_mob_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'current_user',
      senderName: 'You',
      receiverId: 'mob_$mobileNumber',
      receiverName: contactName,
      amount: amount,
      currency: '₹',
      note: note.isNotEmpty ? note : 'Paid to $mobileNumber',
      timestamp: DateTime.now(),
      status: 'SUCCESS',
      upiRefId: 'UPI${DateTime.now().millisecondsSinceEpoch}',
      bankName: primaryBank.bankName,
      paymentMethod: 'Mobile Number',
      category: 'UPI',
      details: 'Mobile: $mobileNumber',
    );

    _transactions.insert(0, txn);
    _txnStreamController.add(List.from(_transactions));
    return txn;
  }

  // --- Mobile Recharge ---
  PaymentTransactionModel rechargeMobile({
    required String phone,
    required String operator,
    required double amount,
    required String planDetails,
  }) {
    _deductFromPrimaryBank(amount);
    final txn = PaymentTransactionModel(
      id: 'txn_rch_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'current_user',
      senderName: 'You',
      receiverId: operator.toLowerCase(),
      receiverName: '$operator Prepaid Recharge',
      amount: amount,
      currency: '₹',
      note: '$operator • $phone ($planDetails)',
      timestamp: DateTime.now(),
      status: 'SUCCESS',
      upiRefId: 'RCH${DateTime.now().millisecondsSinceEpoch}',
      bankName: primaryBank.bankName,
      paymentMethod: 'UPI',
      category: 'RECHARGE',
      details: 'Phone: $phone | Plan: $planDetails',
    );

    _transactions.insert(0, txn);
    _txnStreamController.add(List.from(_transactions));
    return txn;
  }

  // --- Electricity Bill Payment ---
  PaymentTransactionModel payElectricityBill({
    required String discom,
    required String consumerId,
    required double amount,
  }) {
    _deductFromPrimaryBank(amount);
    final txn = PaymentTransactionModel(
      id: 'txn_elec_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'current_user',
      senderName: 'You',
      receiverId: discom.toLowerCase(),
      receiverName: discom,
      amount: amount,
      currency: '₹',
      note: 'Electricity Bill • Consumer #$consumerId',
      timestamp: DateTime.now(),
      status: 'SUCCESS',
      upiRefId: 'ELEC${DateTime.now().millisecondsSinceEpoch}',
      bankName: primaryBank.bankName,
      paymentMethod: 'UPI BBPS',
      category: 'ELECTRICITY',
      details: '$discom | Consumer ID: $consumerId',
    );

    _transactions.insert(0, txn);
    _txnStreamController.add(List.from(_transactions));
    return txn;
  }

  // --- FASTag Recharge ---
  PaymentTransactionModel rechargeFastag({
    required String vehicleNo,
    required String bank,
    required double amount,
  }) {
    _deductFromPrimaryBank(amount);
    final txn = PaymentTransactionModel(
      id: 'txn_ft_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'current_user',
      senderName: 'You',
      receiverId: 'fastag_$bank',
      receiverName: 'NETC FASTag ($bank)',
      amount: amount,
      currency: '₹',
      note: 'FASTag Recharge for $vehicleNo',
      timestamp: DateTime.now(),
      status: 'SUCCESS',
      upiRefId: 'TAG${DateTime.now().millisecondsSinceEpoch}',
      bankName: primaryBank.bankName,
      paymentMethod: 'UPI',
      category: 'FASTAG',
      details: 'Vehicle No: $vehicleNo | Issuing Bank: $bank',
    );

    _transactions.insert(0, txn);
    _txnStreamController.add(List.from(_transactions));
    return txn;
  }

  // --- Metro QR Tickets ---
  PaymentTransactionModel bookMetroTicket({
    required String city,
    required String fromStation,
    required String toStation,
    required int passengers,
    required double fare,
  }) {
    _deductFromPrimaryBank(fare);
    final txn = PaymentTransactionModel(
      id: 'txn_mto_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'current_user',
      senderName: 'You',
      receiverId: 'metro_$city',
      receiverName: '$city Metro Rail QR Ticket',
      amount: fare,
      currency: '₹',
      note: '$fromStation ➔ $toStation ($passengers Ticket${passengers > 1 ? 's' : ''})',
      timestamp: DateTime.now(),
      status: 'SUCCESS',
      upiRefId: 'METRO${DateTime.now().millisecondsSinceEpoch}',
      bankName: primaryBank.bankName,
      paymentMethod: 'UPI',
      category: 'METRO',
      details: '$city Metro | $fromStation to $toStation | $passengers Passenger(s)',
    );

    _transactions.insert(0, txn);
    _txnStreamController.add(List.from(_transactions));
    return txn;
  }

  // --- DTH Recharge ---
  PaymentTransactionModel rechargeDth({
    required String operator,
    required String subscriberId,
    required double amount,
  }) {
    _deductFromPrimaryBank(amount);
    final txn = PaymentTransactionModel(
      id: 'txn_dth_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'current_user',
      senderName: 'You',
      receiverId: 'dth_$operator',
      receiverName: '$operator DTH Recharge',
      amount: amount,
      currency: '₹',
      note: 'DTH ID: $subscriberId',
      timestamp: DateTime.now(),
      status: 'SUCCESS',
      upiRefId: 'DTH${DateTime.now().millisecondsSinceEpoch}',
      bankName: primaryBank.bankName,
      paymentMethod: 'UPI',
      category: 'DTH',
      details: '$operator DTH | Subscriber ID: $subscriberId',
    );

    _transactions.insert(0, txn);
    _txnStreamController.add(List.from(_transactions));
    return txn;
  }

  // --- Credit Card Bill ---
  PaymentTransactionModel payCreditCard({
    required String last4,
    required String bank,
    required double amount,
  }) {
    _deductFromPrimaryBank(amount);
    final txn = PaymentTransactionModel(
      id: 'txn_cc_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'current_user',
      senderName: 'You',
      receiverId: 'cc_$bank',
      receiverName: '$bank Credit Card Payment',
      amount: amount,
      currency: '₹',
      note: 'Card ending in •••• $last4',
      timestamp: DateTime.now(),
      status: 'SUCCESS',
      upiRefId: 'CARD${DateTime.now().millisecondsSinceEpoch}',
      bankName: primaryBank.bankName,
      paymentMethod: 'UPI',
      category: 'CREDIT_CARD',
      details: '$bank Credit Card ending with $last4',
    );

    _transactions.insert(0, txn);
    _txnStreamController.add(List.from(_transactions));
    return txn;
  }

  // --- Loan EMI Payment ---
  PaymentTransactionModel payLoanEmi({
    required String lender,
    required String loanNo,
    required double amount,
  }) {
    _deductFromPrimaryBank(amount);
    final txn = PaymentTransactionModel(
      id: 'txn_loan_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'current_user',
      senderName: 'You',
      receiverId: 'loan_$lender',
      receiverName: '$lender EMI Repayment',
      amount: amount,
      currency: '₹',
      note: 'Loan Account #$loanNo',
      timestamp: DateTime.now(),
      status: 'SUCCESS',
      upiRefId: 'EMI${DateTime.now().millisecondsSinceEpoch}',
      bankName: primaryBank.bankName,
      paymentMethod: 'UPI',
      category: 'LOAN',
      details: '$lender | Loan Account: $loanNo',
    );

    _transactions.insert(0, txn);
    _txnStreamController.add(List.from(_transactions));
    return txn;
  }

  // --- Travel / Movie Tickets ---
  PaymentTransactionModel bookTravelTickets({
    required String type, // 'Bus', 'Train', 'Flight', 'Movie'
    required String details,
    required double amount,
  }) {
    _deductFromPrimaryBank(amount);
    final txn = PaymentTransactionModel(
      id: 'txn_tkt_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'current_user',
      senderName: 'You',
      receiverId: 'tkt_${type.toLowerCase()}',
      receiverName: '$type Booking Confirmation',
      amount: amount,
      currency: '₹',
      note: details,
      timestamp: DateTime.now(),
      status: 'SUCCESS',
      upiRefId: 'TKT${DateTime.now().millisecondsSinceEpoch}',
      bankName: primaryBank.bankName,
      paymentMethod: 'UPI',
      category: 'TICKETS',
      details: '$type Booking | $details',
    );

    _transactions.insert(0, txn);
    _txnStreamController.add(List.from(_transactions));
    return txn;
  }

  // --- Subscriptions ---
  void upgradePlan(String planId) {
    _activePlanId = planId;
    if (planId != 'free') {
      _cloudStorageUsedMb += 100; // simulated backup space allocation
    }
  }

  void cancelSubscription() {
    _activePlanId = 'free';
  }
}
