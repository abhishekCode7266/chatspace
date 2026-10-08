import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';
import '../utils/constants.dart';
import '../screens/qr_code_share_screen.dart';

/// Comprehensive Google Pay / PhonePe / Paytm style Payments Ecosystem
/// Features:
/// - Scan any UPI QR Code
/// - Pay to Mobile Number / Contacts
/// - Receive Money / Accept Payment QR (with custom amount & simulate received)
/// - Check Bank Account Balance (4-Digit PIN)
/// - Mobile Recharge (Jio, Airtel, Vi, BSNL)
/// - Electricity Bill Payment (UPPCL, BSES, BESCOM, etc.)
/// - FASTag Recharge & NETC Tolls
/// - Metro QR Tickets (Delhi, Mumbai, Bengaluru Metro)
/// - DTH, Credit Card Bill & Loan EMI Repayment
/// - Travel & Movie Tickets Booking
/// - Transaction History with Category Filters & Shareable Digital Receipts
/// - 24/7 Help & Support Center
class PaymentsScreen extends StatefulWidget {
  final String? initialReceiverName;
  final String? initialReceiverId;

  const PaymentsScreen({
    super.key,
    this.initialReceiverName,
    this.initialReceiverId,
  });

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final PaymentService _paymentService = PaymentService.instance;
  String _historyFilter = 'All'; // 'All', 'Paid', 'Received', 'Recharge', 'Bills'

  @override
  void initState() {
    super.initState();
    if (widget.initialReceiverName != null && widget.initialReceiverId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSendMoneyDialog(
          prefilledName: widget.initialReceiverName,
          prefilledId: widget.initialReceiverId,
        );
      });
    }
  }

  // ==========================================
  // 1. CHECK BANK BALANCE DIALOG (UPI PIN)
  // ==========================================
  void _showCheckBalanceDialog(BankAccountModel bank) {
    final pinController = TextEditingController();
    bool isError = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 24,
              left: 24,
              right: 24,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2C34) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.security_rounded, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Enter 4-Digit UPI PIN (${bank.bankName})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Default PIN is 1234 for instant testing',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pinController,
                  obscureText: true,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: '••••',
                    errorText: isError ? 'Incorrect UPI PIN. Try 1234' : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (_paymentService.verifyUpiPin(pinController.text.trim())) {
                        Navigator.pop(ctx);
                        _showBalanceRevealedDialog(bank);
                      } else {
                        setModalState(() {
                          isError = true;
                        });
                      }
                    },
                    child: const Text('Confirm PIN & View Balance', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showBalanceRevealedDialog(BankAccountModel bank) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                bank.bankName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account: ${bank.accountNumberMasked}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            const Text('Available Account Balance:', style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              '₹${bank.balance.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. PAY TO MOBILE NUMBER / CONTACTS DIALOG
  // ==========================================
  void _showPayToMobileDialog() {
    final phoneController = TextEditingController();
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final pinController = TextEditingController();
    bool isStepPin = false;
    bool isPinError = false;

    final mockContacts = [
      {'name': 'Aarav Sharma', 'phone': '9876543210'},
      {'name': 'Priya Patel', 'phone': '9812345678'},
      {'name': 'Rohan Gupta', 'phone': '9723456789'},
      {'name': 'Sneha Rao', 'phone': '9634567890'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 24,
              left: 24,
              right: 24,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2C34) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phone_android_rounded, color: Colors.green),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isStepPin ? 'Enter UPI PIN' : 'Pay to Mobile Number (पे मोबाइल नंबर पे)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (!isStepPin) ...[
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number (10 digits)',
                      prefixText: '+91 ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.dialpad_rounded),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Quick Contact Suggestions
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: mockContacts.map((c) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            avatar: CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Text(c['name']![0], style: const TextStyle(fontSize: 12, color: Colors.white)),
                            ),
                            label: Text(c['name']!),
                            onPressed: () {
                              setModalState(() {
                                phoneController.text = c['phone']!;
                                nameController.text = c['name']!;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Contact / Beneficiary Name',
                      hintText: 'e.g. Aarav Sharma',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.person_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Amount (रुपये)',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final amt = double.tryParse(amountController.text.trim()) ?? 0;
                        final phone = phoneController.text.trim();
                        if (amt <= 0 || phone.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter valid mobile number and amount.')),
                          );
                          return;
                        }
                        setModalState(() {
                          isStepPin = true;
                        });
                      },
                      child: const Text('Proceed to Pay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ] else ...[
                  Text(
                    'Paying ₹${amountController.text.trim()} to ${nameController.text.isNotEmpty ? nameController.text.trim() : phoneController.text.trim()}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  const Text('Enter 4-Digit UPI PIN (Default: 1234)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pinController,
                    obscureText: true,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '••••',
                      errorText: isPinError ? 'Invalid UPI PIN. Try 1234' : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (_paymentService.verifyUpiPin(pinController.text.trim())) {
                          final amt = double.tryParse(amountController.text.trim()) ?? 0;
                          final txn = _paymentService.payToMobile(
                            mobileNumber: phoneController.text.trim(),
                            contactName: nameController.text.trim().isNotEmpty ? nameController.text.trim() : 'Contact',
                            amount: amt,
                          );
                          Navigator.pop(ctx);
                          setState(() {});
                          _showTransactionReceipt(txn);
                        } else {
                          setModalState(() {
                            isPinError = true;
                          });
                        }
                      },
                      child: const Text('Confirm Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // 3. RECEIVE MONEY / ACCEPT PAYMENT QR DIALOG
  // ==========================================
  void _showReceiveMoneyQrDialog() {
    final customAmountController = TextEditingController();
    double? customAmount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          final primaryBank = _paymentService.primaryBank;

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 24,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2C34) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0F2F1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.qr_code_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Receive Money (पेमेंट प्राप्त करें QR)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                          Text('Scan with any UPI App (GPay, PhonePe, Paytm)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Simulated Beautiful QR Code Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primary,
                            child: const Text('U', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          const Text('Universal Pay UPI', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Matrix QR Pattern Simulation
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(190, 190),
                              painter: _MockQrCodePainter(),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 28),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        primaryBank.upiId,
                        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      if (customAmount != null && customAmount! > 0) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Text(
                            'Amount: ₹${customAmount!.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Set Amount Option
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: customAmountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: 'Set Amount (optional)',
                          prefixText: '₹ ',
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setModalState(() {
                          customAmount = double.tryParse(customAmountController.text.trim());
                        });
                      },
                      child: const Text('Set', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Simulated Action: "Simulate Receiving Payment"
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_downward_rounded, color: Colors.white),
                    label: const Text('Simulate Incoming Payment (पेमेंट प्राप्त हुआ)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final amt = customAmount ?? 500.0;
                      final incomingTxn = _paymentService.receiveMoneySimulated(
                        amount: amt,
                        senderName: 'Rohit Verma',
                        senderUpi: 'rohit@paytm',
                        note: 'Scanned Universal Pay QR',
                      );
                      Navigator.pop(ctx);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('🔔 Received ₹${amt.toStringAsFixed(2)} from Rohit Verma via UPI QR!'),
                          backgroundColor: Colors.green.shade700,
                        ),
                      );
                      _showTransactionReceipt(incomingTxn);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // 4. SEND MONEY TO UPI / ANY NAME DIALOG
  // ==========================================
  void _showSendMoneyDialog({String? prefilledName, String? prefilledId}) {
    final nameController = TextEditingController(text: prefilledName ?? '');
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final pinController = TextEditingController();
    bool isStepPin = false;
    bool isPinError = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 24,
              left: 24,
              right: 24,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2C34) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_upward_rounded, color: Colors.green),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isStepPin ? 'Enter UPI PIN to Confirm' : 'Send Money (पैसे भेजें)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (!isStepPin) ...[
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Recipient Name or UPI ID',
                      hintText: 'e.g. Alice Johnson / alice@oksbi',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.person_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Amount (रुपये)',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      labelText: 'Add a note (optional)',
                      hintText: 'e.g. Dinner split, Project invoice',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.note_alt_rounded),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final amt = double.tryParse(amountController.text.trim()) ?? 0;
                        if (amt <= 0 || nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter valid recipient and amount.')),
                          );
                          return;
                        }
                        setModalState(() {
                          isStepPin = true;
                        });
                      },
                      child: const Text('Proceed to Enter PIN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ] else ...[
                  Text(
                    'Sending ₹${amountController.text.trim()} to ${nameController.text.trim()}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text('Enter 4-Digit UPI PIN (Default: 1234)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pinController,
                    obscureText: true,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '••••',
                      errorText: isPinError ? 'Invalid UPI PIN. Try 1234' : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (_paymentService.verifyUpiPin(pinController.text.trim())) {
                          final amt = double.tryParse(amountController.text.trim()) ?? 0;
                          final txn = _paymentService.sendMoney(
                            senderId: 'current_user',
                            senderName: 'You',
                            receiverId: prefilledId ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
                            receiverName: nameController.text.trim(),
                            amount: amt,
                            note: noteController.text.trim(),
                          );
                          Navigator.pop(ctx);
                          setState(() {});
                          _showTransactionReceipt(txn);
                        } else {
                          setModalState(() {
                            isPinError = true;
                          });
                        }
                      },
                      child: const Text('Confirm & Send Money', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // 5. MOBILE RECHARGE DIALOG
  // ==========================================
  void _showMobileRechargeDialog() {
    final phoneController = TextEditingController();
    String selectedOperator = 'Jio';
    double selectedAmount = 299;
    String selectedPlan = '2GB/Day + Unlimited 5G • 28 Days';

    final plans = [
      {'amt': 239.0, 'desc': '1.5GB/Day + Unlimited Calls • 28 Days'},
      {'amt': 299.0, 'desc': '2GB/Day + Unlimited 5G • 28 Days'},
      {'amt': 666.0, 'desc': '1.5GB/Day + 100 SMS/Day • 84 Days'},
      {'amt': 999.0, 'desc': '3GB/Day Hero Unlimited • 84 Days'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 24,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2C34) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Color(0xFFE3F2FD), shape: BoxShape.circle),
                      child: const Icon(Icons.cell_tower_rounded, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    const Text('Mobile Recharge (मोबाइल रिचार्ज)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    prefixText: '+91 ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Select Operator:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                Row(
                  children: ['Jio', 'Airtel', 'Vi', 'BSNL'].map((op) {
                    final isSel = selectedOperator == op;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(op),
                        selected: isSel,
                        onSelected: (val) {
                          setModalState(() {
                            selectedOperator = op;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                const Text('Popular Plans:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                ...plans.map((p) {
                  final isSel = selectedAmount == p['amt'];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: isSel ? AppColors.primary : Colors.transparent, width: 1.5),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: Text('₹${p['amt']!.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      title: Text(p['desc'] as String, style: const TextStyle(fontSize: 12)),
                      trailing: isSel ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                      onTap: () {
                        setModalState(() {
                          selectedAmount = p['amt'] as double;
                          selectedPlan = p['desc'] as String;
                        });
                      },
                    ),
                  );
                }),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final phone = phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : '9876543210';
                      final txn = _paymentService.rechargeMobile(
                        phone: phone,
                        operator: selectedOperator,
                        amount: selectedAmount,
                        planDetails: selectedPlan,
                      );
                      Navigator.pop(ctx);
                      setState(() {});
                      _showTransactionReceipt(txn);
                    },
                    child: Text('Recharge ₹${selectedAmount.toInt()} Now', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // 6. ELECTRICITY BILL DIALOG
  // ==========================================
  void _showElectricityBillDialog() {
    final consumerIdController = TextEditingController();
    String selectedDiscom = 'UPPCL (Uttar Pradesh Power)';
    double billAmount = 1420.0;

    final discoms = [
      'UPPCL (Uttar Pradesh Power)',
      'BSES Rajdhani (Delhi)',
      'BESCOM (Bengaluru)',
      'Tata Power (Mumbai)',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 24,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2C34) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Color(0xFFFFF3E0), shape: BoxShape.circle),
                      child: const Icon(Icons.bolt_rounded, color: Colors.orange),
                    ),
                    const SizedBox(width: 12),
                    const Text('Electricity Bill (बिजली का बिल)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedDiscom,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'State Electricity Board',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: discoms.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setModalState(() {
                        selectedDiscom = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: consumerIdController,
                  decoration: InputDecoration(
                    labelText: 'Consumer Number / Account ID',
                    hintText: 'e.g. 1029384756',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A3942) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Bill Due Amount:', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('₹${billAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final cId = consumerIdController.text.trim().isNotEmpty ? consumerIdController.text.trim() : '1029384756';
                      final txn = _paymentService.payElectricityBill(
                        discom: selectedDiscom,
                        consumerId: cId,
                        amount: billAmount,
                      );
                      Navigator.pop(ctx);
                      setState(() {});
                      _showTransactionReceipt(txn);
                    },
                    child: const Text('Pay Electricity Bill Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // 7. METRO QR TICKETS DIALOG
  // ==========================================
  void _showMetroTicketsDialog() {
    String selectedCity = 'Delhi Metro';
    String fromStation = 'Rajiv Chowk';
    String toStation = 'Noida Sector 18';
    int passengers = 1;
    double farePerTicket = 40.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          final totalFare = farePerTicket * passengers;

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 24,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2C34) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Color(0xFFEDE7F6), shape: BoxShape.circle),
                      child: const Icon(Icons.subway_rounded, color: Colors.deepPurple),
                    ),
                    const SizedBox(width: 12),
                    const Text('Metro QR Tickets (मेट्रो टिकट्स)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: ['Delhi Metro', 'Mumbai Metro', 'Bengaluru Metro'].map((city) {
                    final isSel = selectedCity == city;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(city, style: const TextStyle(fontSize: 12)),
                        selected: isSel,
                        onSelected: (val) {
                          setModalState(() {
                            selectedCity = city;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: fromStation),
                        onChanged: (val) => fromStation = val,
                        decoration: InputDecoration(
                          labelText: 'From Station',
                          prefixIcon: const Icon(Icons.trip_origin_rounded, color: Colors.green, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward_rounded, color: Colors.grey),
                    ),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: toStation),
                        onChanged: (val) => toStation = val,
                        decoration: InputDecoration(
                          labelText: 'To Station',
                          prefixIcon: const Icon(Icons.location_on_rounded, color: Colors.red, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Number of Passengers:', style: TextStyle(fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            if (passengers > 1) {
                              setModalState(() => passengers--);
                            }
                          },
                        ),
                        Text('$passengers', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            if (passengers < 6) {
                              setModalState(() => passengers++);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A3942) : Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Fare (₹40 x passengers):', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('₹${totalFare.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final txn = _paymentService.bookMetroTicket(
                        city: selectedCity,
                        fromStation: fromStation,
                        toStation: toStation,
                        passengers: passengers,
                        fare: totalFare,
                      );
                      Navigator.pop(ctx);
                      setState(() {});
                      _showMetroTicketReceiptDialog(txn, fromStation, toStation, passengers);
                    },
                    child: Text('Book QR Ticket (₹${totalFare.toInt()})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showMetroTicketReceiptDialog(PaymentTransactionModel txn, String from, String to, int passengers) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(20)),
              child: const Text('🚇 ACTIVE METRO QR PASS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(height: 14),
            // Simulated Metro Scanner QR Code
            Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurple, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomPaint(
                size: const Size(160, 160),
                painter: _MockQrCodePainter(),
              ),
            ),
            const SizedBox(height: 10),
            Text('$from ➔ $to', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text('$passengers Passenger(s) • Valid for 120 Minutes', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 10),
            Text('Fare Paid: ₹${txn.amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            Text('Token: ${txn.upiRefId}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 8. FASTAG RECHARGE DIALOG
  // ==========================================
  void _showFastagDialog() {
    final vehicleController = TextEditingController();
    String selectedBank = 'ICICI Bank FASTag';
    double amount = 500.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 24,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2C34) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Color(0xFFFBE9E7), shape: BoxShape.circle),
                      child: const Icon(Icons.directions_car_rounded, color: Colors.deepOrange),
                    ),
                    const SizedBox(width: 12),
                    const Text('FASTag Recharge (फास्टैग रिचार्ज)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: vehicleController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'Vehicle Registration Number',
                    hintText: 'e.g. DL 01 AB 1234',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedBank,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'FASTag Issuing Bank',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ['ICICI Bank FASTag', 'SBI FASTag', 'Paytm Payments Bank', 'IDFC FIRST Bank FASTag']
                      .map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedBank = val);
                  },
                ),
                const SizedBox(height: 14),
                const Text('Quick Recharge Amount:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [200.0, 500.0, 1000.0, 2000.0].map((amt) {
                    final isSel = amount == amt;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('₹${amt.toInt()}'),
                        selected: isSel,
                        onSelected: (val) => setModalState(() => amount = amt),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final vNo = vehicleController.text.trim().isNotEmpty ? vehicleController.text.trim().toUpperCase() : 'DL 01 AB 1234';
                      final txn = _paymentService.rechargeFastag(
                        vehicleNo: vNo,
                        bank: selectedBank,
                        amount: amount,
                      );
                      Navigator.pop(ctx);
                      setState(() {});
                      _showTransactionReceipt(txn);
                    },
                    child: Text('Recharge ₹${amount.toInt()} Now', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // 9. DTH / CREDIT CARD / LOAN REPAYMENT
  // ==========================================
  void _showGenericUtilityDialog({required String title, required String fieldLabel, required String category, required double defaultAmount}) {
    final idController = TextEditingController();
    final amountController = TextEditingController(text: defaultAmount.toInt().toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          top: 24,
          left: 20,
          right: 20,
        ),
        decoration: BoxDecoration(
          color: Theme.of(ctx).brightness == Brightness.dark ? const Color(0xFF1F2C34) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            TextField(
              controller: idController,
              decoration: InputDecoration(
                labelText: fieldLabel,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (रुपये)',
                prefixText: '₹ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final amt = double.tryParse(amountController.text.trim()) ?? defaultAmount;
                  PaymentTransactionModel txn;
                  if (category == 'DTH') {
                    txn = _paymentService.rechargeDth(operator: 'Tata Play', subscriberId: idController.text.trim().isNotEmpty ? idController.text.trim() : '10293847', amount: amt);
                  } else if (category == 'CREDIT_CARD') {
                    txn = _paymentService.payCreditCard(last4: idController.text.trim().isNotEmpty ? idController.text.trim() : '4821', bank: 'HDFC Bank', amount: amt);
                  } else {
                    txn = _paymentService.payLoanEmi(lender: 'Bajaj Finance', loanNo: idController.text.trim().isNotEmpty ? idController.text.trim() : 'LN-84920', amount: amt);
                  }
                  Navigator.pop(ctx);
                  setState(() {});
                  _showTransactionReceipt(txn);
                },
                child: const Text('Pay with UPI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 10. 24/7 HELP & SUPPORT CENTER
  // ==========================================
  void _showHelpSupportDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(ctx).brightness == Brightness.dark ? const Color(0xFF1F2C34) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.support_agent_rounded, color: AppColors.primary, size: 28),
                SizedBox(width: 10),
                Text('24/7 Payment Support (मदद व सहायता)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Have an issue with a transaction, refund, or bill payment? We are here 24/7.', style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.report_problem_rounded, color: Colors.orange),
              title: const Text('Raise a Dispute / Report Failed Transaction'),
              subtitle: const Text('Auto-refund initiated within 2 business days'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dispute ticket #UPI-9942 created. Our team is reviewing.')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
              title: const Text('Chat with AI Payment Assistant'),
              subtitle: const Text('Instant answers regarding UPI, limits, and bank servers'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Connecting to Universal AI Payment Assistant...')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.phone_in_talk_rounded, color: Colors.blue),
              title: const Text('Toll-Free Helpline'),
              subtitle: const Text('1800-888-PAY (24/7 Active)'),
              onTap: () {
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 11. TRANSACTION RECEIPT MODAL
  // ==========================================
  void _showTransactionReceipt(PaymentTransactionModel txn) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final isSuccess = txn.status == 'SUCCESS';
        final isIncoming = txn.receiverId == 'current_user';

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2C34) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSuccess ? Colors.green.shade50 : Colors.amber.shade50,
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle_rounded : Icons.access_time_rounded,
                  color: isSuccess ? Colors.green : Colors.amber,
                  size: 48,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isSuccess
                    ? (isIncoming ? 'Payment Received Successfully!' : 'Payment Successful!')
                    : 'Payment Pending',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${txn.amount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              const Divider(),
              _receiptRow('Recipient / Source', isIncoming ? txn.senderName : txn.receiverName),
              _receiptRow('Category', txn.category),
              _receiptRow('UPI Reference ID', txn.upiRefId),
              _receiptRow('Bank / Method', '${txn.bankName} (${txn.paymentMethod})'),
              _receiptRow('Date & Time', DateFormat('dd MMM yyyy, hh:mm a').format(txn.timestamp)),
              if (txn.note.isNotEmpty) _receiptRow('Note', txn.note),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Share Receipt'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payment Receipt shared successfully!')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Done', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _receiptRow(String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Expanded(
            child: Text(
              val,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BUILD METHOD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBank = _paymentService.primaryBank;

    // Filter transactions
    final allTxns = _paymentService.transactions;
    final filteredTxns = allTxns.where((t) {
      if (_historyFilter == 'Paid') return t.senderId == 'current_user';
      if (_historyFilter == 'Received') return t.receiverId == 'current_user';
      if (_historyFilter == 'Recharge') return t.category == 'RECHARGE' || t.category == 'FASTAG' || t.category == 'DTH';
      if (_historyFilter == 'Bills') return t.category == 'ELECTRICITY' || t.category == 'METRO' || t.category == 'CREDIT_CARD' || t.category == 'LOAN';
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Universal Pay (पेमेंट्स)', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.support_agent_rounded),
            tooltip: '24/7 Help & Support',
            onPressed: _showHelpSupportDialog,
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Scan Any QR Code',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QrCodeShareScreen(initialTabIndex: 1)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // TOP UPI ACCOUNT CARD (GPay style)
            // ==========================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF005C4B), Color(0xFF075E54)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF005C4B).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                        child: const Icon(Icons.shield_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Universal Pay UPI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                          Text('Secured by Bank-Grade 256-Bit E2EE', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.account_balance_wallet_rounded, size: 14, color: Color(0xFF005C4B)),
                        label: const Text('Check Balance', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF005C4B))),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => _showCheckBalanceDialog(primaryBank),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('UPI ID (आपकी यूपीआई आईडी):', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    primaryBank.upiId,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Primary: ${primaryBank.bankName} (${primaryBank.accountNumberMasked}) • Balance: ₹${primaryBank.balance.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ==========================================
            // PRIMARY 4 ACTIONS GRID (Pay Mobile, Receive QR, Scan QR, Send Money)
            // ==========================================
            Row(
              children: [
                _buildMainActionTile(
                  icon: Icons.qr_code_scanner_rounded,
                  color: const Color(0xFF007AFF),
                  label: 'Scan Any\nQR Code',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QrCodeShareScreen(initialTabIndex: 1)),
                    );
                  },
                ),
                const SizedBox(width: 10),
                _buildMainActionTile(
                  icon: Icons.phone_android_rounded,
                  color: const Color(0xFF2E7D32),
                  label: 'Pay to\nMobile No.',
                  onTap: _showPayToMobileDialog,
                ),
                const SizedBox(width: 10),
                _buildMainActionTile(
                  icon: Icons.qr_code_2_rounded,
                  color: const Color(0xFF6A1B9A),
                  label: 'Receive\nMoney QR',
                  onTap: _showReceiveMoneyQrDialog,
                ),
                const SizedBox(width: 10),
                _buildMainActionTile(
                  icon: Icons.send_rounded,
                  color: const Color(0xFF00897B),
                  label: 'Send\nMoney',
                  onTap: () => _showSendMoneyDialog(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ==========================================
            // RECHARGE & BILL PAYMENTS SECTION (PhonePe Grid)
            // ==========================================
            const Text(
              'Recharge & Pay Bills (रिचार्ज और बिल भुगतान)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2C34) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildUtilityIcon(
                        icon: Icons.cell_tower_rounded,
                        color: Colors.blue,
                        label: 'Mobile\nRecharge',
                        onTap: _showMobileRechargeDialog,
                      ),
                      _buildUtilityIcon(
                        icon: Icons.bolt_rounded,
                        color: Colors.orange,
                        label: 'Electricity\nBill',
                        onTap: _showElectricityBillDialog,
                      ),
                      _buildUtilityIcon(
                        icon: Icons.directions_car_rounded,
                        color: Colors.deepOrange,
                        label: 'FASTag\nRecharge',
                        onTap: _showFastagDialog,
                      ),
                      _buildUtilityIcon(
                        icon: Icons.subway_rounded,
                        color: Colors.deepPurple,
                        label: 'Metro\nTickets',
                        onTap: _showMetroTicketsDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildUtilityIcon(
                        icon: Icons.tv_rounded,
                        color: Colors.red,
                        label: 'DTH\nCable',
                        onTap: () => _showGenericUtilityDialog(
                          title: 'DTH Recharge (डीटीएच रिचार्ज)',
                          fieldLabel: 'Subscriber ID / SmartCard Number',
                          category: 'DTH',
                          defaultAmount: 350.0,
                        ),
                      ),
                      _buildUtilityIcon(
                        icon: Icons.credit_card_rounded,
                        color: Colors.teal,
                        label: 'Credit\nCard',
                        onTap: () => _showGenericUtilityDialog(
                          title: 'Credit Card Bill Payment',
                          fieldLabel: 'Card Number (Last 4 digits)',
                          category: 'CREDIT_CARD',
                          defaultAmount: 4850.0,
                        ),
                      ),
                      _buildUtilityIcon(
                        icon: Icons.account_balance_rounded,
                        color: Colors.indigo,
                        label: 'Loan\nPayment',
                        onTap: () => _showGenericUtilityDialog(
                          title: 'Loan EMI Repayment',
                          fieldLabel: 'Loan Account Number',
                          category: 'LOAN',
                          defaultAmount: 2500.0,
                        ),
                      ),
                      _buildUtilityIcon(
                        icon: Icons.confirmation_number_rounded,
                        color: Colors.pink,
                        label: 'Book\nTickets',
                        onTap: () {
                          final txn = _paymentService.bookTravelTickets(
                            type: 'Bus',
                            details: 'Express Volvo • Delhi to Jaipur (Seat 14A)',
                            amount: 750.0,
                          );
                          setState(() {});
                          _showTransactionReceipt(txn);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==========================================
            // LINKED BANK ACCOUNTS
            // ==========================================
            Row(
              children: [
                const Text(
                  'Linked Bank Accounts (बैंक खाते)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Simulated: New Bank Account linked successfully!')),
                    );
                  },
                  child: const Text('+ Add Bank'),
                ),
              ],
            ),

            ..._paymentService.bankAccounts.map((b) => _buildBankAccountCard(b, isDark)),

            const SizedBox(height: 24),

            // ==========================================
            // TRANSACTION HISTORY & CATEGORY FILTERS
            // ==========================================
            Row(
              children: [
                const Text(
                  'Transaction History (इतिहास)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text('${filteredTxns.length} records', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Paid', 'Received', 'Recharge', 'Bills'].map((filter) {
                  final isSel = _historyFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter, style: TextStyle(fontSize: 12, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                      selected: isSel,
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                      onSelected: (val) {
                        setState(() {
                          _historyFilter = filter;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            if (filteredTxns.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_rounded, size: 48, color: Colors.grey.withOpacity(0.4)),
                      const SizedBox(height: 8),
                      const Text('No transactions in this filter', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else
              ...filteredTxns.map((txn) => _buildTransactionTile(txn, isDark)),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================
  Widget _buildMainActionTile({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUtilityIcon({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankAccountCard(BankAccountModel bank, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: bank.isPrimary ? AppColors.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(bank.brandColorHex).withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.account_balance_rounded, color: Color(bank.brandColorHex)),
        ),
        title: Text(bank.bankName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('A/C: ${bank.accountNumberMasked} • ${bank.accountType}\nUPI: ${bank.upiId}'),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (bank.isPrimary)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('PRIMARY', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            const SizedBox(height: 4),
            TextButton(
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
              onPressed: () => _showCheckBalanceDialog(bank),
              child: const Text('Check Balance', style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(PaymentTransactionModel txn, bool isDark) {
    final isIncoming = txn.receiverId == 'current_user';
    final isSuccess = txn.status == 'SUCCESS';

    IconData catIcon = Icons.payment_rounded;
    Color catColor = isIncoming ? Colors.green : Colors.red;

    if (txn.category == 'RECHARGE') {
      catIcon = Icons.cell_tower_rounded;
      catColor = Colors.blue;
    } else if (txn.category == 'ELECTRICITY') {
      catIcon = Icons.bolt_rounded;
      catColor = Colors.orange;
    } else if (txn.category == 'METRO') {
      catIcon = Icons.subway_rounded;
      catColor = Colors.deepPurple;
    } else if (txn.category == 'FASTAG') {
      catIcon = Icons.directions_car_rounded;
      catColor = Colors.deepOrange;
    } else if (txn.category == 'CREDIT_CARD') {
      catIcon = Icons.credit_card_rounded;
      catColor = Colors.teal;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () => _showTransactionReceipt(txn),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: catColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(catIcon, color: catColor, size: 22),
        ),
        title: Text(
          isIncoming ? txn.senderName : txn.receiverName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          '${DateFormat('dd MMM, hh:mm a').format(txn.timestamp)} • ${txn.paymentMethod}\n${txn.note.isNotEmpty ? txn.note : txn.upiRefId}',
          style: const TextStyle(fontSize: 11),
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isIncoming ? '+' : '-'} ₹${txn.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isIncoming ? Colors.green : (isDark ? Colors.white : Colors.black87),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isSuccess ? 'Success' : txn.status,
              style: TextStyle(fontSize: 10, color: isSuccess ? Colors.green : Colors.amber, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simulated matrix QR painter
class _MockQrCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Corner Finder Patterns
    _drawFinderPattern(canvas, 10, 10, paint);
    _drawFinderPattern(canvas, size.width - 50, 10, paint);
    _drawFinderPattern(canvas, 10, size.height - 50, paint);

    // Random-looking matrix blocks
    const step = 8.0;
    for (double x = 10; x < size.width - 10; x += step) {
      for (double y = 10; y < size.height - 10; y += step) {
        if ((x < 55 && y < 55) || (x > size.width - 55 && y < 55) || (x < 55 && y > size.height - 55)) {
          continue;
        }
        if ((x.toInt() * y.toInt()) % 13 == 0 || (x.toInt() + y.toInt()) % 7 == 0) {
          canvas.drawRect(Rect.fromLTWH(x, y, step - 1, step - 1), paint);
        }
      }
    }
  }

  void _drawFinderPattern(Canvas canvas, double x, double y, Paint paint) {
    canvas.drawRect(Rect.fromLTWH(x, y, 40, 40), paint);
    canvas.drawRect(Rect.fromLTWH(x + 6, y + 6, 28, 28), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(x + 12, y + 12, 16, 16), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
