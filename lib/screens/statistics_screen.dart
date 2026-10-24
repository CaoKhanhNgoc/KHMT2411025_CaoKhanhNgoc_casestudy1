import 'dart:math';
import 'package:flutter/material.dart';
import '../database.dart';
import '../utils/app_constants.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = 'Tháng này';
  bool _isLoading = true;

  double _totalExpense = 5000000.0;
  List<CategoryStat> _categoryStats = [];

  final List<String> _periods = ['Tháng này', 'Tháng trước', 'Năm nay'];

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final transactions = await DatabaseHelper.instance.getTransactions();

    final Map<String, double> categorySums = {};
    double totalExp = 0;

    for (final t in transactions) {
      final type = t['type']?.toString() ?? '';
      if (type == 'Chi tiêu' || type == 'expense') {
        final amount = (t['amount'] as num?)?.toDouble() ?? 0.0;
        final cat = t['category']?.toString() ?? 'Khác';
        categorySums[cat] = (categorySums[cat] ?? 0.0) + amount;
        totalExp += amount;
      }
    }

    if (totalExp > 0) {
      final List<CategoryStat> stats = [];
      categorySums.forEach((cat, amount) {
        final percentage = (amount / totalExp) * 100;
        stats.add(
          CategoryStat(
            category: cat,
            amount: amount,
            percentage: percentage,
            color: _getStatColor(cat),
          ),
        );
      });
      // Sắp xếp giảm dần theo số tiền
      stats.sort((a, b) => b.amount.compareTo(a.amount));

      if (mounted) {
        setState(() {
          _totalExpense = totalExp;
          _categoryStats = stats;
          _isLoading = false;
        });
      }
    } else {
      // Mock data hiển thị đúng như trong ảnh khi chưa có dữ liệu
      if (mounted) {
        setState(() {
          _totalExpense = 5000000.0;
          _categoryStats = [
            CategoryStat(
              category: 'Ăn uống',
              amount: 2000000.0,
              percentage: 40.0,
              color: const Color(0xFFFF5252),
            ),
            CategoryStat(
              category: 'Mua sắm',
              amount: 1500000.0,
              percentage: 30.0,
              color: const Color(0xFFFF9800),
            ),
            CategoryStat(
              category: 'Đi lại',
              amount: 700000.0,
              percentage: 14.0,
              color: const Color(0xFF22C55E),
            ),
            CategoryStat(
              category: 'Học tập',
              amount: 500000.0,
              percentage: 10.0,
              color: const Color(0xFF3B82F6),
            ),
            CategoryStat(
              category: 'Khác',
              amount: 300000.0,
              percentage: 6.0,
              color: const Color(0xFFA855F7),
            ),
          ];
          _isLoading = false;
        });
      }
    }
  }

  Color _getStatColor(String category) {
    switch (category) {
      case 'Ăn uống':
        return const Color(0xFFFF5252);
      case 'Mua sắm':
        return const Color(0xFFFF9800);
      case 'Đi lại':
        return const Color(0xFF22C55E);
      case 'Học tập':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFFA855F7);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Thống kê',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // TAB CHỌN THỜI GIAN (Tháng này / Tháng trước / Năm nay)
                    _buildPeriodTabs(),

                    const SizedBox(height: 24),

                    // BIỂU ĐỒ DONUT
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: CustomPaint(
                        painter: DonutChartPainter(
                          stats: _categoryStats,
                          totalAmount: _totalExpense,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                CategoryHelper.formatCurrency(_totalExpense),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Tổng chi tiêu',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.grayText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // DANH SÁCH CHI TIẾT DANH MỤC
                    ..._categoryStats.map((stat) => _buildStatItem(stat)),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPeriodTabs() {
    return Row(
      children: _periods.map((period) {
        final bool isSelected = _selectedPeriod == period;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedPeriod = period);
              },
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  period,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.grayText,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatItem(CategoryStat stat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Dấu chấm màu
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: stat.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),

          // Tên danh mục
          Expanded(
            child: Text(
              stat.category,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.darkText,
              ),
            ),
          ),

          // Số tiền
          Text(
            CategoryHelper.formatCurrency(stat.amount),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),

          const SizedBox(width: 16),

          // Phần trăm
          SizedBox(
            width: 36,
            child: Text(
              '${stat.percentage.toStringAsFixed(0)}%',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.grayText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryStat {
  final String category;
  final double amount;
  final double percentage;
  final Color color;

  CategoryStat({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}

class DonutChartPainter extends CustomPainter {
  final List<CategoryStat> stats;
  final double totalAmount;

  DonutChartPainter({
    required this.stats,
    required this.totalAmount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (stats.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    const strokeWidth = 24.0;

    double startAngle = -pi / 2;

    for (final stat in stats) {
      final sweepAngle = (stat.percentage / 100) * 2 * pi;

      final paint = Paint()
        ..color = stat.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
