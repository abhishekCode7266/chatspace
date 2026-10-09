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
  String _upiNumber = '9876543210';
  String get upiNumber => _upiNumber;
  void updateUpiNumber(String newNum) => _upiNumber = newNum;

  String _paymentProvider = 'NPCI UPI 2.0 Engine';
  String get paymentProvider => _paymentProvider;
  void switchPaymentProvider(String provider) => _paymentProvider = provider;

  bool verifyUpiPin(String enteredPin) {
    return enteredPin == _upiPin;
  }

  void updateUpiPin(String newPin) {
    if (newPin.length == 4) {
      _upiPin = newPin;
    }
  }

  bool changeUpiPin(String oldPin, String newPin) {
    if (verifyUpiPin(oldPin) && newPin.length == 4) {
      _upiPin = newPin;
      return true;
    }
    return false;
  }

  bool resetUpiPin(String otp, String newPin) {
    if (otp.trim().isNotEmpty && newPin.length == 4) {
      _upiPin = newPin;
      return true;
    }
    return false;
  }

  // --- AI Assistance (100% Free & Unlimited) ---
  bool canUseAi() => true;
  void recordAiQuery() {
    _aiQueriesUsedToday++;
  }
  void resetDailyAiQuota() {
    _aiQueriesUsedToday = 0;
  }

  // --- Reward Coins System (रिवॉर्ड कॉइन्स) ---
  // Milestone: ₹500+ = 1 coin, ₹1000+ = 2 coins, ₹2000+ = 3 coins. 100 coins = ₹1 cashback
  int _rewardCoins = 180; // 180 coins = ₹1.80
  int get rewardCoins => _rewardCoins;

  void awardCoinsForTxn(double amount) {
    if (amount >= 2000) {
      _rewardCoins += 3;
    } else if (amount >= 1000) {
      _rewardCoins += 2;
    } else if (amount >= 500) {
      _rewardCoins += 1;
    }
  }

  bool redeemRewardCoins({int coinsToRedeem = 100}) {
    if (_rewardCoins >= coinsToRedeem && coinsToRedeem >= 100) {
      final double cashback = (coinsToRedeem / 100).floorToDouble() * 1.0;
      final int usedCoins = (cashback * 100).toInt();
      _rewardCoins -= usedCoins;
      _addToPrimaryBank(cashback);

      final txn = PaymentTransactionModel(
        id: 'txn_coin_${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'universal_rewards',
        senderName: 'Universal Reward Coins (रिवॉर्ड कॉइन्स)',
        receiverId: 'current_user',
        receiverName: 'You',
        amount: cashback,
        currency: '₹',
        note: 'Cashback from $usedCoins Reward Coins (100 coins = ₹1)',
        timestamp: DateTime.now(),
        status: 'SUCCESS',
        upiRefId: 'COIN${DateTime.now().millisecondsSinceEpoch}',
        bankName: primaryBank.bankName,
        paymentMethod: 'Reward Cashback',
        category: 'UPI',
        details: 'Redeemed $usedCoins coins to Bank Account',
      );
      _transactions.insert(0, txn);
      _txnStreamController.add(List.from(_transactions));
      return true;
    }
    return false;
  }

  // --- Free CIBIL Credit Score Check ---
  int get cibilScore => 785;
  String get cibilRating => 'Excellent (शानदार)';
  String get cibilSummary => 'Strong repayment history, zero late payments, 12% credit utilization.';

  // --- UPI LITE (PIN-less 1-Click Payments up to ₹500) ---
  bool _isUpiLiteActive = true;
  double _upiLiteBalance = 500.0;
  bool get isUpiLiteActive => _isUpiLiteActive;
  double get upiLiteBalance => _upiLiteBalance;

  void topUpUpiLite(double amount) {
    _deductFromPrimaryBank(amount);
    _upiLiteBalance += amount;
  }

  PaymentTransactionModel payViaUpiLite({
    required String receiverName,
    required double amount,
    String note = '1-Click PIN-less UPI LITE payment',
  }) {
    _upiLiteBalance = (_upiLiteBalance - amount).clamp(0.0, 2000.0);
    awardCoinsForTxn(amount);
    final txn = PaymentTransactionModel(
      id: 'txn_lite_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'current_user',
      senderName: 'You',
      receiverId: 'upi_lite_rec',
      receiverName: receiverName,
      amount: amount,
      currency: '₹',
      note: note,
      timestamp: DateTime.now(),
      status: 'SUCCESS',
      upiRefId: 'LITE${DateTime.now().millisecondsSinceEpoch}',
      bankName: 'UPI LITE Wallet',
      paymentMethod: 'UPI LITE',
      category: 'UPI',
      details: 'Instant 1-Click Payment without PIN',
    );
    _transactions.insert(0, txn);
    _txnStreamController.add(List.from(_transactions));
    return txn;
  }

  // --- AutoPay Recurring Subscriptions & Mandates ---
  final List<Map<String, dynamic>> _autoPayMandates = [
    {
      'title': 'Netflix India Premium',
      'frequency': 'Monthly',
      'amount': 649.0,
      'nextDate': '25 Oct 2026',
      'bank': 'State Bank of India',
      'status': 'ACTIVE',
      'icon': 'movie',
    },
    {
      'title': 'Spotify Premium Family',
      'frequency': 'Monthly',
      'amount': 179.0,
      'nextDate': '12 Nov 2026',
      'bank': 'HDFC Bank',
      'status': 'ACTIVE',
      'icon': 'music_note',
    },
    {
      'title': 'JioFiber 100Mbps Broadband',
      'frequency': 'Monthly',
      'amount': 825.0,
      'nextDate': '01 Nov 2026',
      'bank': 'State Bank of India',
      'status': 'ACTIVE',
      'icon': 'wifi',
    },
  ];

  List<Map<String, dynamic>> get autoPayMandates => List.unmodifiable(_autoPayMandates);

  void addAutoPayMandate({
    required String title,
    required String frequency,
    required double amount,
    required String nextDate,
    required String bank,
  }) {
    _autoPayMandates.add({
      'title': title,
      'frequency': frequency,
      'amount': amount,
      'nextDate': nextDate,
      'bank': bank,
      'status': 'ACTIVE',
      'icon': 'autorenew',
    });
  }

  // --- Bank Operations ---
  void addBankAccount(BankAccountModel account) {
    _bankAccounts.add(account);
  }

  bool removeBankAccount(String bankId) {
    if (_bankAccounts.length > 1) {
      _bankAccounts.removeWhere((b) => b.id == bankId);
      if (!_bankAccounts.any((b) => b.isPrimary) && _bankAccounts.isNotEmpty) {
        _bankAccounts[0] = BankAccountModel(
          id: _bankAccounts[0].id,
          bankName: _bankAccounts[0].bankName,
          accountNumberMasked: _bankAccounts[0].accountNumberMasked,
          ifsc: _bankAccounts[0].ifsc,
          accountType: _bankAccounts[0].accountType,
          isPrimary: true,
          upiId: _bankAccounts[0].upiId,
          balance: _bankAccounts[0].balance,
          brandColorHex: _bankAccounts[0].brandColorHex,
          isInternational: _bankAccounts[0].isInternational,
          country: _bankAccounts[0].country,
        );
      }
      return true;
    }
    return false;
  }

  BankAccountModel addNewBankAccount({
    required String bankName,
    required String accountNumber,
    String? ifscOrSwift,
    String? ifscCode,
    String? accountHolderName,
    String accountType = 'Savings',
    bool isPrimary = false,
    bool isInternational = false,
    String country = 'India',
    int? brandColorHex,
  }) {
    final effectiveIfsc = (ifscOrSwift ?? ifscCode ?? 'SBIN0001234').toUpperCase();
    final effectiveHolder = (accountHolderName != null && accountHolderName.isNotEmpty) ? accountHolderName : 'user';
    final last4 = accountNumber.length >= 4 ? accountNumber.substring(accountNumber.length - 4) : '0000';
    final safeBankCode = bankName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final effectiveColor = brandColorHex ?? (isInternational ? 0xFF0D47A1 : 0xFF003366);
    final newAcc = BankAccountModel(
      id: 'bank_${DateTime.now().millisecondsSinceEpoch}',
      bankName: bankName,
      accountNumberMasked: '•••• $last4',
      ifsc: effectiveIfsc,
      accountType: accountType,
      isPrimary: isPrimary,
      upiId: '${effectiveHolder.toLowerCase().replaceAll(' ', '')}@ok$safeBankCode',
      balance: 10000.0 + (DateTime.now().millisecond * 20),
      brandColorHex: effectiveColor,
      isInternational: isInternational,
      country: country,
    );

    if (isPrimary) {
      setPrimaryBank(newAcc.id);
    }
    _bankAccounts.add(newAcc);
    return newAcc;
  }

  static const List<Map<String, dynamic>> allSupportedBanks = [
    // Popular Indian Banks
    {'name': 'State Bank of India', 'code': 'SBIN', 'country': 'India', 'isInternational': false, 'popular': true, 'color': 0xFF003366},
    {'name': 'HDFC Bank', 'code': 'HDFC', 'country': 'India', 'isInternational': false, 'popular': true, 'color': 0xFF004B87},
    {'name': 'ICICI Bank', 'code': 'ICIC', 'country': 'India', 'isInternational': false, 'popular': true, 'color': 0xFF9C1D26},
    {'name': 'Punjab National Bank', 'code': 'PUNB', 'country': 'India', 'isInternational': false, 'popular': true, 'color': 0xFFA00028},
    {'name': 'Bank of Baroda', 'code': 'BARB', 'country': 'India', 'isInternational': false, 'popular': true, 'color': 0xFFF26522},
    {'name': 'Axis Bank', 'code': 'UTIB', 'country': 'India', 'isInternational': false, 'popular': true, 'color': 0xFF97144D},
    {'name': 'Kotak Mahindra Bank', 'code': 'KKBK', 'country': 'India', 'isInternational': false, 'popular': true, 'color': 0xFFED1C24},
    {'name': 'Canara Bank', 'code': 'CNRB', 'country': 'India', 'isInternational': false, 'popular': true, 'color': 0xFF0085C8},
    {'name': 'Union Bank of India', 'code': 'UBIN', 'country': 'India', 'isInternational': false, 'popular': true, 'color': 0xFF005A9C},
    {'name': 'IndusInd Bank', 'code': 'INDB', 'country': 'India', 'isInternational': false, 'popular': false, 'color': 0xFF8B1D41},
    {'name': 'IDFC FIRST Bank', 'code': 'IDFB', 'country': 'India', 'isInternational': false, 'popular': false, 'color': 0xFF9D2235},
    {'name': 'Yes Bank', 'code': 'YESB', 'country': 'India', 'isInternational': false, 'popular': false, 'color': 0xFF00519E},
    {'name': 'Federal Bank', 'code': 'FDRL', 'country': 'India', 'isInternational': false, 'popular': false, 'color': 0xFF002B49},
    {'name': 'Central Bank of India', 'code': 'CBIN', 'country': 'India', 'isInternational': false, 'popular': false, 'color': 0xFF004A80},
    {'name': 'Indian Bank', 'code': 'IDIB', 'country': 'India', 'isInternational': false, 'popular': false, 'color': 0xFF1B365D},
    {'name': 'UCO Bank', 'code': 'UCBA', 'country': 'India', 'isInternational': false, 'popular': false, 'color': 0xFF00539B},
    {'name': 'Bank of India', 'code': 'BKID', 'country': 'India', 'isInternational': false, 'popular': false, 'color': 0xFFE31B23},
    {'name': 'Punjab & Sind Bank', 'code': 'PSIB', 'country': 'India', 'isInternational': false, 'popular': false, 'color': 0xFFBF1E2E},
    {'name': 'RBL Bank', 'code': 'RATN', 'country': 'India', 'isInternational': false, 'popular': false, 'color': 0xFF0C2074},
    {'name': 'Bandhan Bank', 'code': 'BDBL', 'country': 'India', 'isInternational': false, 'popular': false, 'color': 0xFF003057},
    {'name': 'Paytm Payments Bank', 'code': 'PYTM', 'country': 'India', 'isInternational': false, 'popular': true, 'color': 0xFF00B9F5},
    {'name': 'Airtel Payments Bank', 'code': 'AIRP', 'country': 'India', 'isInternational': false, 'popular': true, 'color': 0xFFE40000},
    {'name': 'India Post Payments Bank (IPPB)', 'code': 'IPOS', 'country': 'India', 'isInternational': false, 'popular': false, 'color': 0xFFED1C24},
    {'name': 'Jio Payments Bank', 'code': 'JIOP', 'country': 'India', 'isInternational': false, 'popular': false, 'color': 0xFF0A2885},
    {'name': 'AU Small Finance Bank', 'code': 'AUBL', 'country': 'India', 'isInternational': false, 'popular': false, 'color': 0xFF6C1D45},
    {'name': 'Equitas Small Finance Bank', 'code': 'ESFB', 'country': 'India', 'isInternational': false, 'popular': false, 'color': 0xFF00529B},
    {'name': 'South Indian Bank', 'code': 'SIBL', 'country': 'India', 'isInternational': false, 'popular': false, 'color': 0xFFBF2026},
    {'name': 'Karur Vysya Bank', 'code': 'KVBL', 'country': 'India', 'isInternational': false, 'popular': false, 'color': 0xFF003366},
    {'name': 'Karnataka Bank', 'code': 'KARB', 'country': 'India', 'isInternational': false, 'popular': false, 'color': 0xFF8A1538},
    {'name': 'Standard Chartered India', 'code': 'SCBL', 'country': 'India', 'isInternational': false, 'popular': false, 'color': 0xFF007A3D},
    {'name': 'Citibank India', 'code': 'CITI', 'country': 'India', 'isInternational': false, 'popular': false, 'color': 0xFF003B70},
    {'name': 'HSBC India', 'code': 'HSBC', 'country': 'India', 'isInternational': false, 'popular': false, 'color': 0xFFDB0011},
    {'name': 'DBS Bank India', 'code': 'DBSS', 'country': 'India', 'isInternational': false, 'popular': false, 'color': 0xFFFF3300},

    // International Banks
    {'name': 'JPMorgan Chase', 'code': 'CHASUS', 'country': 'United States', 'isInternational': true, 'popular': true, 'color': 0xFF117ACA},
    {'name': 'Bank of America', 'code': 'BOFAUS', 'country': 'United States', 'isInternational': true, 'popular': true, 'color': 0xFFE31837},
    {'name': 'Wells Fargo', 'code': 'WFBIUS', 'country': 'United States', 'isInternational': true, 'popular': true, 'color': 0xFFD71E28},
    {'name': 'Citibank Global', 'code': 'CITIUS', 'country': 'United States', 'isInternational': true, 'popular': true, 'color': 0xFF003B70},
    {'name': 'Goldman Sachs', 'code': 'GSCOUS', 'country': 'United States', 'isInternational': true, 'popular': false, 'color': 0xFF004B87},
    {'name': 'Morgan Stanley', 'code': 'MSCOUS', 'country': 'United States', 'isInternational': true, 'popular': false, 'color': 0xFF1C355E},
    {'name': 'HSBC Global', 'code': 'MIDLGB', 'country': 'United Kingdom', 'isInternational': true, 'popular': true, 'color': 0xFFDB0011},
    {'name': 'Barclays Bank', 'code': 'BARCGB', 'country': 'United Kingdom', 'isInternational': true, 'popular': true, 'color': 0xFF00AEEF},
    {'name': 'Lloyds Bank', 'code': 'LOYDGB', 'country': 'United Kingdom', 'isInternational': true, 'popular': false, 'color': 0xFF006A4E},
    {'name': 'Standard Chartered Global', 'code': 'SCBLGB', 'country': 'United Kingdom', 'isInternational': true, 'popular': false, 'color': 0xFF007A3D},
    {'name': 'Deutsche Bank', 'code': 'DEUTDE', 'country': 'Germany', 'isInternational': true, 'popular': true, 'color': 0xFF0018A8},
    {'name': 'Commerzbank', 'code': 'COBADE', 'country': 'Germany', 'isInternational': true, 'popular': false, 'color': 0xFFFFCC00},
    {'name': 'BNP Paribas', 'code': 'BNPAFR', 'country': 'France', 'isInternational': true, 'popular': true, 'color': 0xFF00965E},
    {'name': 'Crédit Agricole', 'code': 'AGRIFR', 'country': 'France', 'isInternational': true, 'popular': false, 'color': 0xFF006D44},
    {'name': 'Société Générale', 'code': 'SOGEFR', 'country': 'France', 'isInternational': true, 'popular': false, 'color': 0xFFE2001A},
    {'name': 'UBS Group', 'code': 'UBSWCH', 'country': 'Switzerland', 'isInternational': true, 'popular': true, 'color': 0xFFE60000},
    {'name': 'Santander Bank', 'code': 'BSCHES', 'country': 'Spain', 'isInternational': true, 'popular': true, 'color': 0xFFEC0000},
    {'name': 'BBVA', 'code': 'BBVAES', 'country': 'Spain', 'isInternational': true, 'popular': false, 'color': 0xFF004481},
    {'name': 'ING Bank', 'code': 'INGBNL', 'country': 'Netherlands', 'isInternational': true, 'popular': false, 'color': 0xFFFF6200},
    {'name': 'Royal Bank of Canada (RBC)', 'code': 'ROYCCA', 'country': 'Canada', 'isInternational': true, 'popular': false, 'color': 0xFF0051A5},
    {'name': 'Toronto-Dominion Bank (TD)', 'code': 'TDOMCA', 'country': 'Canada', 'isInternational': true, 'popular': false, 'color': 0xFF008A00},
    {'name': 'Bank of Nova Scotia (Scotiabank)', 'code': 'NOSCCA', 'country': 'Canada', 'isInternational': true, 'popular': false, 'color': 0xFFEE1C25},
    {'name': 'Mitsubishi UFJ (MUFG)', 'code': 'BOTKJP', 'country': 'Japan', 'isInternational': true, 'popular': false, 'color': 0xFFE60012},
    {'name': 'Sumitomo Mitsui (SMBC)', 'code': 'SMBCJP', 'country': 'Japan', 'isInternational': true, 'popular': false, 'color': 0xFF007536},
    {'name': 'Mizuho Bank', 'code': 'MHCBJP', 'country': 'Japan', 'isInternational': true, 'popular': false, 'color': 0xFF002244},
    {'name': 'DBS Bank Global', 'code': 'DBSSSG', 'country': 'Singapore', 'isInternational': true, 'popular': true, 'color': 0xFFFF3300},
    {'name': 'OCBC Bank', 'code': 'OCBCSG', 'country': 'Singapore', 'isInternational': true, 'popular': false, 'color': 0xFFED1C24},
    {'name': 'United Overseas Bank (UOB)', 'code': 'UOVBSG', 'country': 'Singapore', 'isInternational': true, 'popular': false, 'color': 0xFF002060},
    {'name': 'Bank of China', 'code': 'BKCHCN', 'country': 'China', 'isInternational': true, 'popular': false, 'color': 0xFFB1001C},
    {'name': 'Industrial and Commercial Bank of China (ICBC)', 'code': 'ICBCCN', 'country': 'China', 'isInternational': true, 'popular': false, 'color': 0xFFC7000B},
    {'name': 'Commonwealth Bank of Australia', 'code': 'CTBAAU', 'country': 'Australia', 'isInternational': true, 'popular': false, 'color': 0xFFFFCC00},
    {'name': 'Westpac Banking Corp', 'code': 'WPACAU', 'country': 'Australia', 'isInternational': true, 'popular': false, 'color': 0xFFDA1710},
    {'name': 'ANZ Bank', 'code': 'ANZBAU', 'country': 'Australia', 'isInternational': true, 'popular': false, 'color': 0xFF007DBA},
    {'name': 'Emirates NBD', 'code': 'EBILAE', 'country': 'United Arab Emirates', 'isInternational': true, 'popular': false, 'color': 0xFF002060},
    {'name': 'First Abu Dhabi Bank (FAB)', 'code': 'NBADAE', 'country': 'United Arab Emirates', 'isInternational': true, 'popular': false, 'color': 0xFF005596},
    {'name': 'Qatar National Bank (QNB)', 'code': 'QNBAQA', 'country': 'Qatar', 'isInternational': true, 'popular': false, 'color': 0xFF5D1224},
  ];

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
        isInternational: b.isInternational,
        country: b.country,
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
    _deductFromPrimaryBank(amount);
    awardCoinsForTxn(amount);
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
    awardCoinsForTxn(amount);
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
    awardCoinsForTxn(amount);
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
