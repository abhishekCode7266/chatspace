import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';
import '../utils/constants.dart';

/// Premium Subscription & Extra Cloud Storage Screen
/// Allows users to upgrade to Universal Pro for Unlimited AI, 100GB extra cloud backup,
/// Ad-Free experience, and Business Enterprise accounts.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final PaymentService _paymentService = PaymentService.instance;
  bool _isYearly = false;
  bool _isProcessing = false;

  void _upgradeToPlan(SubscriptionPlanModel plan) {
    if (plan.id == _paymentService.activePlanId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are already subscribed to ${plan.name}!'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    if (plan.id == 'free') {
      setState(() {
        _paymentService.cancelSubscription();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Switched to Free Starter plan.')),
      );
      return;
    }

    // Show simulated UPI / Payment confirmation sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildPaymentSheet(plan),
    );
  }

  Widget _buildPaymentSheet(SubscriptionPlanModel plan) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final price = _isYearly ? plan.priceYearly : plan.priceMonthly;
    final period = _isYearly ? 'year' : 'month';

    return Container(
      padding: const EdgeInsets.all(24),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upgrade to ${plan.name}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₹${price.toStringAsFixed(0)} / $period • Instant Activation',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          const Text(
            'Payment Method (भुगतान माध्यम):',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 1.5),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.primary.withOpacity(0.08),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_rounded, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _paymentService.primaryBank.bankName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        'UPI: ${_paymentService.primaryBank.upiId}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle_rounded, color: AppColors.primary),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isProcessing = true;
                });
                Future.delayed(const Duration(milliseconds: 1200), () {
                  if (!mounted) return;
                  setState(() {
                    _isProcessing = false;
                    _paymentService.upgradePlan(plan.id);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🎉 Congratulations! ${plan.name} activated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                });
              },
              child: Text(
                'Pay ₹${price.toStringAsFixed(0)} & Activate Pro',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activePlan = _paymentService.plans.firstWhere(
      (p) => p.id == _paymentService.activePlanId,
      orElse: () => _paymentService.plans.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium & Cloud Storage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset AI Quota (Dev Test)',
            onPressed: () {
              setState(() {
                _paymentService.resetDailyAiQuota();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Daily Free AI Quota reset to 15!')),
              );
            },
          ),
        ],
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade700,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star_rounded, color: Colors.white, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'UNIVERSAL PRO',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            if (_paymentService.isPremiumUser)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade600,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'ACTIVE SUBSCRIBER',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Unleash Unlimited Meta AI & Extra Cloud Storage',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Current plan: ${activePlan.name} • ${_paymentService.cloudStorageLimitGb}GB Total Cloud Backup',
                          style: TextStyle(color: Colors.cyanAccent.shade100, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Cloud Storage Usage Meter Card
                  _buildCloudStorageMeter(isDark),

                  const SizedBox(height: 20),

                  // Monthly / Yearly Billing Toggle
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F2C34) : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _isYearly = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                color: !_isYearly ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Monthly (मासिक)',
                                style: TextStyle(
                                  color: !_isYearly ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _isYearly = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                color: _isYearly ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Yearly (वार्षिक)',
                                    style: TextStyle(
                                      color: _isYearly ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'SAVE 16%',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Plans Comparison List
                  ..._paymentService.plans.map((plan) => _buildPlanCard(plan, isDark)),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildCloudStorageMeter(bool isDark) {
    final usedMb = _paymentService.cloudStorageUsedMb;
    final totalGb = _paymentService.cloudStorageLimitGb;
    final totalMb = totalGb * 1024;
    final progress = (usedMb / totalMb).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2C34) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_done_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              const Text(
                'Cloud Backup Storage',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              Text(
                '${(usedMb / 1024).toStringAsFixed(2)} GB / $totalGb GB',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? Colors.black26 : Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress > 0.85 ? Colors.redAccent : AppColors.primary,
            ),
            borderRadius: BorderRadius.circular(8),
            minHeight: 8,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Daily Meta AI: ${_paymentService.isPremiumUser ? "Unlimited ⚡" : "${_paymentService.remainingFreeAiQueries} free queries left"}',
                style: TextStyle(
                  fontSize: 12,
                  color: _paymentService.isPremiumUser ? Colors.amber.shade700 : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (!_paymentService.isPremiumUser)
                const Text(
                  'Upgrade for 100GB extra',
                  style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlanModel plan, bool isDark) {
    final isCurrent = plan.id == _paymentService.activePlanId;
    final price = _isYearly ? plan.priceYearly : plan.priceMonthly;
    final period = _isYearly ? 'yr' : 'mo';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2C34) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: plan.isPopular
              ? Colors.amber
              : isCurrent
                  ? AppColors.primary
                  : Colors.grey.withOpacity(0.2),
          width: plan.isPopular || isCurrent ? 2.0 : 1.0,
        ),
        boxShadow: plan.isPopular
            ? [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                plan.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              if (plan.isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'MOST POPULAR',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black),
                  ),
                ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'CURRENT PLAN',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            plan.tagline,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                plan.priceMonthly == 0 ? 'Free' : '₹${price.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              if (plan.priceMonthly > 0) ...[
                const SizedBox(width: 4),
                Text(
                  '/$period',
                  style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
              ],
              const Spacer(),
              Text(
                '${plan.cloudStorageGb}GB Cloud',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...plan.keyFeatures.map((feat) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        feat,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrent
                    ? Colors.grey.shade400
                    : plan.isPopular
                        ? Colors.amber.shade700
                        : AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: isCurrent ? null : () => _upgradeToPlan(plan),
              child: Text(
                isCurrent
                    ? 'Active Plan (सक्रिय)'
                    : plan.priceMonthly == 0
                        ? 'Select Free'
                        : 'Upgrade to ${plan.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
