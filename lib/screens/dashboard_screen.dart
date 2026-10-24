import 'package:flutter/material.dart';
import '../database.dart';
import '../utils/app_constants.dart';
import 'transaction_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onSeeAll;

  const DashboardScreen({super.key, this.onSeeAll});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _recentTransactions = [];
  double _balance = 5000000.0;
  double _totalIncome = 10000000.0;
  double _totalExpense = 5000000.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final data = await DatabaseHelper.instance.getTransactions();

    double inc = 0;
    double exp = 0;

    for (final t in data) {
      final amount = (t['amount'] as num?)?.toDouble() ?? 0.0;
      final type = t['type']?.toString() ?? '';
      if (type == 'Thu nhập' || type == 'income') {
        inc += amount;
      } else {
        exp += amount;
      }
    }

    if (mounted) {
      setState(() {
        _recentTransactions = data.take(5).toList();
        _totalIncome = inc;
        _totalExpense = exp;
        _balance = inc - exp;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // ===== HEADER XANH DƯƠNG + CARD SỐ DƯ =====
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // NỀN XANH DƯƠNG PHÍA TRÊN
                        Container(
                          width: double.infinity,
                          height: 180,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Xin chào!',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Hôm nay là một ngày tốt lành!',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // CARD SỐ DƯ HIỆN TẠI NỔI LÊN TRÊN
                        Positioned(
                          top: 110,
                          left: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Số dư hiện tại',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.grayText,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      CategoryHelper.formatCurrency(_balance),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkText,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet,
                                    color: AppColors.primaryBlue,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),

                    // ===== 2 CARD: THU NHẬP & CHI TIÊU =====
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          // CARD THU NHẬP
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.incomeLightGreen,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: AppColors.incomeGreen.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_upward,
                                      size: 16,
                                      color: AppColors.incomeGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Thu nhập',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.grayText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    CategoryHelper.formatCurrency(_totalIncome),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.incomeGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // CARD CHI TIÊU
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.expenseLightRed,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: AppColors.expenseRed.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_downward,
                                      size: 16,
                                      color: AppColors.expenseRed,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Chi tiêu',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.grayText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    CategoryHelper.formatCurrency(_totalExpense),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.expenseRed,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ===== CHI TIÊU GẦN ĐÂY =====
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Chi tiêu gần đây',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkText,
                            ),
                          ),
                          GestureDetector(
                            onTap: widget.onSeeAll,
                            child: const Text(
                              'Xem tất cả',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // DANH SÁCH GIAO DỊCH GẦN ĐÂY
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _recentTransactions.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(24),
                                child: Center(
                                  child: Text(
                                    'Chưa có giao dịch nào',
                                    style: TextStyle(color: AppColors.grayText),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                itemCount: _recentTransactions.length,
                                separatorBuilder: (_, __) => const Divider(
                                  height: 1,
                                  color: Color(0xFFF1F5F9),
                                ),
                                itemBuilder: (context, index) {
                                  final item = _recentTransactions[index];
                                  return _buildTransactionItem(item);
                                },
                              ),
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

      // NÚT THÊM (+)
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TransactionFormScreen(isEdit: false),
            ),
          );
          if (result == true) {
            _loadDashboardData();
          }
        },
        backgroundColor: AppColors.primaryBlue,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> item) {
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
          _loadDashboardData();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
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
            Text(
              (isIncome ? '+' : '-') + CategoryHelper.formatCurrency(amount),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isIncome ? AppColors.incomeGreen : AppColors.expenseRed,
              ),
            ),
            const SizedBox(width: 6),
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
