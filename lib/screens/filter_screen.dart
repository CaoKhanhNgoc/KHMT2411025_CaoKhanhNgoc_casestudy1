import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

class FilterCriteria {
  final String transactionType; // 'Tất cả', 'Thu nhập', 'Chi tiêu'
  final String category; // 'Tất cả danh mục' or specific category
  final String timeRange; // 'Hôm nay', '7 ngày qua', 'Tháng này', 'Tùy chỉnh'

  FilterCriteria({
    this.transactionType = 'Tất cả',
    this.category = 'Tất cả danh mục',
    this.timeRange = 'Hôm nay',
  });
}

class FilterScreen extends StatefulWidget {
  final FilterCriteria? initialCriteria;

  const FilterScreen({super.key, this.initialCriteria});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late String _selectedType;
  late String _selectedCategory;
  late String _selectedTimeRange;

  final List<String> _categories = [
    'Tất cả danh mục',
    'Ăn uống',
    'Mua sắm',
    'Lương',
    'Đi lại',
    'Học tập',
    'Khác',
  ];

  final List<String> _timeRanges = [
    'Hôm nay',
    '7 ngày qua',
    'Tháng này',
    'Tùy chỉnh',
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialCriteria?.transactionType ?? 'Tất cả';
    _selectedCategory = widget.initialCriteria?.category ?? 'Tất cả danh mục';
    _selectedTimeRange = widget.initialCriteria?.timeRange ?? 'Hôm nay';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bộ lọc',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== 1. LOẠI GIAO DỊCH =====
                    const Text(
                      'Loại giao dịch',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildCheckboxOption('Tất cả'),
                    _buildCheckboxOption('Thu nhập'),
                    _buildCheckboxOption('Chi tiêu'),

                    const SizedBox(height: 24),

                    // ===== 2. DANH MỤC =====
                    const Text(
                      'Danh mục',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.grayText),
                          items: _categories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat,
                              child: Text(
                                cat,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.darkText,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedCategory = val);
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ===== 3. KHOẢNG THỜI GIAN =====
                    const Text(
                      'Khoảng thời gian',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._timeRanges.map((range) => _buildRadioOption(range)),
                  ],
                ),
              ),
            ),

            // NÚT ÁP DỤNG
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final result = FilterCriteria(
                      transactionType: _selectedType,
                      category: _selectedCategory,
                      timeRange: _selectedTimeRange,
                    );
                    Navigator.pop(context, result);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Áp dụng',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxOption(String title) {
    final bool isChecked = _selectedType == title;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = title;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isChecked ? AppColors.primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isChecked ? AppColors.primaryBlue : AppColors.borderColor,
                  width: 1.5,
                ),
              ),
              child: isChecked
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(String title) {
    final bool isSelected = _selectedTimeRange == title;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTimeRange = title;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : AppColors.borderColor,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
