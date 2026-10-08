import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';
import '../utils/constants.dart';
import '../screens/qr_code_share_screen.dart';

/// WhatsApp Pay & Paytm style in-app payment center
/// Send/receive money via UPI, link bank accounts, check balance,
/// verify 4-digit UPI PIN, and view transaction receipts.
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
  String _historyFilter = 'All'; // 'All', 'Sent', 'Received'

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

  // Check balance dialog
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
                    Text(
                      'Enter 4-Digit UPI PIN (${bank.bankName})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

  // Send Money Dialog / Sheet
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
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.account_balance_rounded, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        'Debit from: ${_paymentService.primaryBank.bankName}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                        if (nameController.text.trim().isEmpty || amt <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter valid recipient and amount.')),
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
                    'Paying ₹${amountController.text.trim()} to ${nameController.text.trim()}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text('Default UPI PIN is 1234', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                      errorText: isPinError ? 'Invalid PIN. Try 1234' : null,
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

  // Transaction Receipt Sheet
  void _showTransactionReceipt(PaymentTransactionModel txn) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

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
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 12),
              const Text(
                'Payment Successful! (भुगतान सफल)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                '₹${txn.amount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              _buildReceiptRow('To (प्राप्तकर्ता)', txn.receiverName),
              _buildReceiptRow('From (भेजने वाला)', txn.senderName),
              _buildReceiptRow('Bank', txn.bankName),
              _buildReceiptRow('UPI Ref ID', txn.upiRefId),
              if (txn.note.isNotEmpty) _buildReceiptRow('Note', txn.note),
              _buildReceiptRow('Date & Time', '${txn.timestamp.day}/${txn.timestamp.month}/${txn.timestamp.year} ${txn.timestamp.hour}:${txn.timestamp.minute.toString().padLeft(2, '0')}'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Share Payment Receipt'),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment receipt copied to share!')),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bank = _paymentService.primaryBank;
    final transactions = _paymentService.transactions;

    final filteredTxns = transactions.where((t) {
      if (_historyFilter == 'Sent') return t.senderId == 'current_user';
      if (_historyFilter == 'Received') return t.receiverId == 'current_user';
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Universal Payments (पेमेंट्स)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_rounded),
            tooltip: 'My Payment QR',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QrCodeShareScreen(initialTabIndex: 0)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top UPI ID Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF075E54), Color(0xFF128C7E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_rounded, size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text('UPI 256-Bit Secure', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Universal Pay',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('UPI ID (आपकी यूपीआई आईडी):', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    bank.upiId,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Primary Bank: ${bank.bankName} (${bank.accountNumberMasked})',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Quick Actions 4 Grid
            Row(
              children: [
                _buildQuickActionTile(
                  icon: Icons.send_rounded,
                  color: Colors.green.shade700,
                  label: 'Send Money\n(पैसे भेजें)',
                  onTap: () => _showSendMoneyDialog(),
                ),
                const SizedBox(width: 10),
                _buildQuickActionTile(
                  icon: Icons.qr_code_scanner_rounded,
                  color: const Color(0xFF007AFF),
                  label: 'Scan QR\n(स्कैन करें)',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QrCodeShareScreen(initialTabIndex: 1)),
                    );
                  },
                ),
                const SizedBox(width: 10),
                _buildQuickActionTile(
                  icon: Icons.account_balance_wallet_rounded,
                  color: Colors.amber.shade800,
                  label: 'Check Balance\n(बैलेंस)',
                  onTap: () => _showCheckBalanceDialog(bank),
                ),
                const SizedBox(width: 10),
                _buildQuickActionTile(
                  icon: Icons.request_quote_rounded,
                  color: Colors.purple.shade700,
                  label: 'Request\n(मांगें)',
                  onTap: () => _showSendMoneyDialog(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Payment Methods / Bank Accounts
            Row(
              children: [
                const Text(
                  'Payment Methods (बैंक खाते)',
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

            // Transaction History Header & Filter Chips
            Row(
              children: [
                const Text(
                  'Payment History (इतिहास)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F2C34) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<String>(
                    value: _historyFilter,
                    underline: const SizedBox(),
                    items: ['All', 'Sent', 'Received'].map((opt) {
                      return DropdownMenuItem(value: opt, child: Text(opt, style: const TextStyle(fontSize: 12)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _historyFilter = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (filteredTxns.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No transactions found in this filter.')),
              )
            else
              ...filteredTxns.map((t) => _buildTransactionTile(t, isDark)),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankAccountCard(BankAccountModel b, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2C34) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: b.isPrimary ? AppColors.primary : Colors.grey.withOpacity(0.2),
          width: b.isPrimary ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(b.brandColorHex),
            child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(b.bankName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    if (b.isPrimary) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Primary', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${b.accountType} Account • ${b.accountNumberMasked}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showCheckBalanceDialog(b),
            child: const Text('Check Balance', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(PaymentTransactionModel t, bool isDark) {
    final isMeSender = t.senderId == 'current_user';
    final sign = isMeSender ? '-' : '+';
    final color = isMeSender ? Colors.black87 : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2C34) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: InkWell(
        onTap: () => _showTransactionReceipt(t),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isMeSender ? Colors.orange.shade100 : Colors.green.shade100,
              child: Icon(
                isMeSender ? Icons.arrow_outward_rounded : Icons.arrow_downward_rounded,
                color: isMeSender ? Colors.orange.shade800 : Colors.green.shade800,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMeSender ? 'Paid to ${t.receiverName}' : 'Received from ${t.senderName}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                  Text(
                    t.note.isNotEmpty ? t.note : 'UPI Transaction',
                    style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$sign₹${t.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
                    color: isDark && isMeSender ? Colors.white : color,
                  ),
                ),
                Text(
                  '${t.timestamp.day}/${t.timestamp.month} ${t.timestamp.hour}:${t.timestamp.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
