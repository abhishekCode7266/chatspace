import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Global Universal Search Screen
/// Filters by: All, Chats, Users, Groups, Media, Documents, Audio, and Date
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedDateFilter = 'All Time';

  final List<Map<String, dynamic>> _allItems = [
    {
      'title': 'Alice Johnson',
      'subtitle': 'Hey, did you review the Universal Chat logo?',
      'category': 'Users',
      'icon': Icons.person_rounded,
      'date': 'Today',
    },
    {
      'title': '🚀 Universal AI & Flutter Devs',
      'subtitle': 'Charlie: v1.4.0 Google Play Store release build is verified! 🚀',
      'category': 'Groups',
      'icon': Icons.group_rounded,
      'date': 'Today',
    },
    {
      'title': 'Universal_Chat_Architecture_Spec.pdf',
      'subtitle': 'Shared in 🚀 Universal AI & Flutter Devs • 4.2 MB',
      'category': 'Documents',
      'icon': Icons.picture_as_pdf_rounded,
      'date': 'Yesterday',
    },
    {
      'title': '3D Neural Globe Logo (universal_chat_icon_512.jpg)',
      'subtitle': 'Image • 604 KB • High Resolution Asset',
      'category': 'Media',
      'icon': Icons.image_rounded,
      'date': 'Yesterday',
    },
    {
      'title': 'Voice Note (0:14)',
      'subtitle': 'From Alice Johnson • High-fidelity audio note',
      'category': 'Audio',
      'icon': Icons.audiotrack_rounded,
      'date': 'Today',
    },
    {
      'title': 'https://github.com/abhishekCode7266/chatspace',
      'subtitle': 'GitHub Repository URL • Production release',
      'category': 'Links',
      'icon': Icons.link_rounded,
      'date': '2 days ago',
    },
    {
      'title': '💡 Tech Innovators',
      'subtitle': 'Diana: End-to-end encryption audit passed with zero vulnerabilities! 🔒',
      'category': 'Groups',
      'icon': Icons.group_rounded,
      'date': '3 days ago',
    },
    {
      'title': 'Bob Smith',
      'subtitle': 'Call me once the Play Store bundle upload is complete.',
      'category': 'Users',
      'icon': Icons.person_rounded,
      'date': '4 days ago',
    },
  ];

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredItems() {
    final query = _queryController.text.trim().toLowerCase();

    return _allItems.where((item) {
      // Category filter
      if (_selectedCategory != 'All') {
        if (item['category'] != _selectedCategory) return false;
      }

      // Date filter
      if (_selectedDateFilter != 'All Time') {
        if (_selectedDateFilter == 'Today' && item['date'] != 'Today') return false;
        if (_selectedDateFilter == 'Yesterday' && item['date'] != 'Yesterday') return false;
      }

      // Query search
      if (query.isNotEmpty) {
        final title = (item['title'] as String).toLowerCase();
        final subtitle = (item['subtitle'] as String).toLowerCase();
        return title.contains(query) || subtitle.contains(query);
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final results = _getFilteredItems();

    const categories = ['All', 'Users', 'Groups', 'Media', 'Documents', 'Audio', 'Links'];
    const dateFilters = ['All Time', 'Today', 'Yesterday'];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _queryController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search chats, messages, files & media...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
          ),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          onChanged: (_) => setState(() {}),
        ),
        actions: [
          if (_queryController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                _queryController.clear();
                setState(() {});
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Horizontal Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                ...categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.primaryLight.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: (sel) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                    ),
                  );
                }),
                const SizedBox(width: 8),
                // Date filter dropdown chip
                PopupMenuButton<String>(
                  initialValue: _selectedDateFilter,
                  onSelected: (val) => setState(() => _selectedDateFilter = val),
                  itemBuilder: (ctx) => dateFilters
                      .map((df) => PopupMenuItem(value: df, child: Text(df)))
                      .toList(),
                  child: Chip(
                    avatar: const Icon(Icons.calendar_today_rounded, size: 14),
                    label: Text(_selectedDateFilter, style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Search Results List
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No results found', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        SizedBox(height: 4),
                        Text('Try adjusting your search keyword or filters', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                          child: Icon(item['icon'] as IconData, color: AppColors.primary),
                        ),
                        title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text(item['subtitle'] as String, maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(item['date'] as String, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Opening ${item['title']}...')),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
