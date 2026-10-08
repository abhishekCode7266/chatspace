import 'package:flutter/material.dart';
import '../models/business_model.dart';
import '../utils/constants.dart';

/// Business Profile & Enterprise Hub
/// Features: Business Profile, Product Catalog, Automated Messaging, Orders Management
class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late BusinessProfileModel _profile;
  final List<ProductModel> _products = [
    ProductModel(
      id: 'prod_01',
      name: 'Universal AI Pro Subscription',
      price: 499.0,
      currency: '₹',
      description: 'Unlimited AI Chat, instant document summarization, voice translation & image generation.',
      imageUrl: 'assets/images/app_logo.jpg',
      inStock: true,
      category: 'AI Services',
    ),
    ProductModel(
      id: 'prod_02',
      name: 'Enterprise E2EE Security Shield',
      price: 1299.0,
      currency: '₹',
      description: 'Zero-knowledge server encryption, dedicated encrypted channels, and priority SLA.',
      imageUrl: 'assets/images/app_logo.jpg',
      inStock: true,
      category: 'Security',
    ),
    ProductModel(
      id: 'prod_03',
      name: 'Multi-Device Sync Cloud Hub',
      price: 299.0,
      currency: '₹',
      description: 'Seamless real-time synchronization across up to 10 desktop, tablet, and web sessions.',
      imageUrl: 'assets/images/app_logo.jpg',
      inStock: true,
      category: 'Cloud',
    ),
  ];

  final List<OrderModel> _orders = [
    OrderModel(
      orderId: 'ORD-9842',
      customerName: 'Alice Johnson',
      productName: 'Universal AI Pro Subscription',
      amount: 499.0,
      status: 'Delivered',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    OrderModel(
      orderId: 'ORD-9843',
      customerName: 'Charlie Dev',
      productName: 'Enterprise E2EE Security Shield',
      amount: 1299.0,
      status: 'Processing',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _profile = BusinessProfileModel(
      businessId: 'biz_universal_01',
      businessName: 'Universal Technologies Inc.',
      category: 'AI & Next-Gen Communications',
      description: 'Empowering businesses with AI assistants, multi-platform messaging, and bank-grade privacy.',
      email: 'enterprise@universalchat.app',
      website: 'https://universalchat.app/business',
      address: 'Tower B, Tech Innovation Hub, Cyber City',
      workingHours: 'Mon - Fri: 8:30 AM - 7:30 PM (IST)',
      isVerified: true,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Product to Catalog'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price (₹)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  _products.add(
                    ProductModel(
                      id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
                      name: nameController.text.trim(),
                      price: double.tryParse(priceController.text) ?? 99.0,
                      description: descController.text.trim(),
                      imageUrl: 'assets/images/app_logo.jpg',
                    ),
                  );
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product added to business catalog!')),
                );
              }
            },
            child: const Text('Save Product'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.storefront_rounded, color: AppColors.primaryLight),
            SizedBox(width: 8),
            Text('Universal Business Hub', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
          tabs: const [
            Tab(icon: Icon(Icons.store_rounded), text: 'Profile'),
            Tab(icon: Icon(Icons.inventory_2_rounded), text: 'Catalog'),
            Tab(icon: Icon(Icons.receipt_long_rounded), text: 'Orders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(isDark),
          _buildCatalogTab(isDark),
          _buildOrdersTab(isDark),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: _showAddProductDialog,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Add Product', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  Widget _buildProfileTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner & Avatar
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      backgroundImage: const AssetImage('assets/images/app_logo.jpg'),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_rounded, color: Colors.white, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _profile.businessName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  _profile.category,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Details List
          _buildInfoTile(Icons.info_outline_rounded, 'About Business', _profile.description, isDark),
          _buildInfoTile(Icons.schedule_rounded, 'Working Hours', _profile.workingHours, isDark),
          _buildInfoTile(Icons.email_outlined, 'Official Email', _profile.email, isDark),
          _buildInfoTile(Icons.language_rounded, 'Official Website', _profile.website, isDark),
          _buildInfoTile(Icons.location_on_outlined, 'Headquarters', _profile.address, isDark),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // Automated Messaging section
          const Text('Automated Business Messages', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Automated Greetings'),
            subtitle: Text(_profile.autoGreetingMessage, style: const TextStyle(fontSize: 12)),
            value: _profile.autoReplyEnabled,
            activeColor: AppColors.primary,
            onChanged: (val) {
              setState(() {
                _profile = BusinessProfileModel(
                  businessId: _profile.businessId,
                  businessName: _profile.businessName,
                  category: _profile.category,
                  description: _profile.description,
                  email: _profile.email,
                  website: _profile.website,
                  address: _profile.address,
                  workingHours: _profile.workingHours,
                  autoReplyEnabled: val,
                );
              });
            },
          ),
          ListTile(
            title: const Text('Away Message'),
            subtitle: Text(_profile.autoAwayMessage, style: const TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.edit_outlined, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogTab(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final prod = _products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    prod.imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              prod.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: prod.inStock ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              prod.inStock ? 'In Stock' : 'Out of Stock',
                              style: TextStyle(
                                color: prod.inStock ? Colors.green : Colors.red,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        prod.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${prod.currency}${prod.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrdersTab(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final ord = _orders[index];
        final isDelivered = ord.status == 'Delivered';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isDelivered ? Colors.green.shade100 : Colors.orange.shade100,
              child: Icon(
                isDelivered ? Icons.check_circle_rounded : Icons.pending_rounded,
                color: isDelivered ? Colors.green : Colors.orange,
              ),
            ),
            title: Text('${ord.productName} • ${ord.orderId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('Customer: ${ord.customerName}\nAmount: ₹${ord.amount.toStringAsFixed(0)}'),
            isThreeLine: true,
            trailing: Chip(
              label: Text(ord.status, style: const TextStyle(fontSize: 11, color: Colors.white)),
              backgroundColor: isDelivered ? Colors.green : Colors.orange,
              padding: EdgeInsets.zero,
            ),
          ),
        );
      },
    );
  }
}
