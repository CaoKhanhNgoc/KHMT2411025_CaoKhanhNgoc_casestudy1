import 'package:flutter/material.dart';
import '../database.dart';
import '../utils/app_constants.dart';
import 'filter_screen.dart';
import 'transaction_form_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  List<Map<String, dynamic>> _allTransactions = [];
  List<Map<String, dynamic>> _filteredTransactions = [];
  bool _isLoading = true;

  String _searchQuery = '';
  String _selectedTab = 'Tất cả'; // 'Tất cả', 'Thu nhập', 'Chi tiêu'
  FilterCriteria? _filterCriteria;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    final data = await DatabaseHelper.instance.getTransactions();
    if (mounted) {
      setState(() {
        _allTransactions = data;
        _isLoading = false;
      });
      _applyFilter();
    }
  }

  void _applyFilter() {
    List<Map<String, dynamic>> results = List.from(_allTransactions);

    // 1. Lọc theo Tab (Tất cả / Thu nhập / Chi tiêu)
    if (_selectedTab == 'Thu nhập') {
      results = results.where((t) {
        final type = t['type']?.toString() ?? '';
        return type == 'Thu nhập' || type == 'income';
      }).toList();
    } else if (_selectedTab == 'Chi tiêu') {
      results = results.where((t) {
        final type = t['type']?.toString() ?? '';
        return type == 'Chi tiêu' || type == 'expense';
      }).toList();
    }

    // 2. Lọc theo tìm kiếm (note hoặc category)
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      results = results.where((t) {
        final note = (t['note'] ?? '').toString().toLowerCase();
        final cat = (t['category'] ?? '').toString().toLowerCase();
        return note.contains(query) || cat.contains(query);
      }).toList();
    }

    // 3. Lọc theo FilterCriteria nếu có
    if (_filterCriteria != null) {
      if (_filterCriteria!.category != 'Tất cả danh mục') {
        results = results.where((t) {
          return t['category'] == _filterCriteria!.category;
        }).toList();
      }

      if (_filterCriteria!.transactionType != 'Tất cả') {
        results = results.where((t) {
          final type = t['type']?.toString() ?? '';
          if (_filterCriteria!.transactionType == 'Thu nhập') {
            return type == 'Thu nhập' || type == 'income';
          } else {
            return type == 'Chi tiêu' || type == 'expense';
          }
        }).toList();
      }
    }

    setState(() {
      _filteredTransactions = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Giao dịch',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // THANH TÌM KIẾM & NÚT BỘ LỌC
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          _searchQuery = val;
                          _applyFilter();
                        },
                        decoration: const InputDecoration(
                          hintText: 'Tìm kiếm giao dịch...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            size: 18,
                            color: Color(0xFF94A3B8),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // NÚT BỘ LỌC
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push<FilterCriteria>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FilterScreen(
                            initialCriteria: _filterCriteria,
                          ),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          _filterCriteria = result;
                        });
                        _applyFilter();
                      }
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _filterCriteria != null
                            ? AppColors.primaryBlueLight
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _filterCriteria != null
                              ? AppColors.primaryBlue
                              : AppColors.borderColor,
                        ),
                      ),
                      child: Icon(
                        Icons.filter_list,
                        size: 20,
                        color: _filterCriteria != null
                            ? AppColors.primaryBlue
                            : AppColors.grayText,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // CÁC PILL TABS (Tất cả / Thu nhập / Chi tiêu)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildPillTab('Tất cả'),
                  const SizedBox(width: 8),
                  _buildPillTab('Thu nhập'),
                  const SizedBox(width: 8),
                  _buildPillTab('Chi tiêu'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // DANH SÁCH GIAO DỊCH
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredTransactions.isEmpty
                      ? const Center(
                          child: Text(
                            'Không tìm thấy giao dịch nào',
                            style: TextStyle(color: AppColors.grayText),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadTransactions,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            itemCount: _filteredTransactions.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              color: Color(0xFFF1F5F9),
                            ),
                            itemBuilder: (context, index) {
                              final item = _filteredTransactions[index];
                              return _buildTransactionRow(item);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillTab(String title) {
    final bool isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = title;
        });
        _applyFilter();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.borderColor,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.grayText,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionRow(Map<String, dynamic> item) {
    final category = item['category']?.toString() ?? 'Khác';
    final date = item['date']?.toString() ?? '';
    final num? amt = item['amount'] as num?;
    final double amount = amt?.toDouble() ?? 0.0;
    final type = item['type']?.toString() ?? '';
    final bool isIncome = (type == 'Thu nhập' || type == 'income');

    final color = CategoryHelper.getColor(category);
    final icon = CategoryHelper.getIcon(category);

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TransactionFormScreen(
              isEdit: true,
              transaction: item,
            ),
          ),
        );
        if (result == true) {
          _loadTransactions();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // ICON TRÒN
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18,
                color: color,
              ),
            ),
            const SizedBox(width: 12),

            // TÊN DANH MỤC + NGÀY
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.grayText,
                    ),
                  ),
                ],
              ),
            ),

            // SỐ TIỀN
            Text(
              (isIncome ? '+' : '-') + CategoryHelper.formatCurrency(amount),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isIncome ? AppColors.incomeGreen : AppColors.expenseRed,
              ),
            ),

            const SizedBox(width: 8),

            // MŨI TÊN
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }
}
