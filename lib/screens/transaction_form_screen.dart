import 'package:flutter/material.dart';
import '../database.dart';
import '../utils/app_constants.dart';

class TransactionFormScreen extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic>? transaction;

  const TransactionFormScreen({
    super.key,
    required this.isEdit,
    this.transaction,
  });

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  bool isExpense = true;
  String category = 'Ăn uống';
  DateTime selectedDate = DateTime(2025, 4, 12);

  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  final List<String> categories = [
    'Ăn uống',
    'Mua sắm',
    'Lương',
    'Đi lại',
    'Học tập',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.isEdit && widget.transaction != null) {
      final t = widget.transaction!;
      isExpense = (t['type'] == 'Chi tiêu' || t['type'] == 'expense');

      final cat = t['category']?.toString() ?? 'Ăn uống';
      if (!categories.contains(cat)) {
        categories.add(cat);
      }
      category = cat;

      final num? amt = t['amount'] as num?;
      if (amt != null) {
        amountController.text = amt.toInt().toString();
      }
      noteController.text = t['note']?.toString() ?? '';

      if (t['date'] != null) {
        try {
          final parts = (t['date'] as String).split('/');
          if (parts.length == 3) {
            selectedDate = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        } catch (_) {}
      }
    } else if (widget.isEdit) {
      // Mock data như hình màn hình 5
      amountController.text = '100.000';
      noteController.text = 'Ăn trưa';
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _deleteTransaction() async {
    if (widget.transaction == null || widget.transaction!['id'] == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa giao dịch này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteTransaction(widget.transaction!['id']);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa giao dịch')),
        );
        Navigator.pop(context, true);
      }
    }
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
        title: Text(
          widget.isEdit ? 'Sửa giao dịch' : 'Thêm giao dịch',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        centerTitle: true,
        actions: [
          if (widget.isEdit && widget.transaction != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _deleteTransaction,
              tooltip: 'Xóa giao dịch',
            ),
        ],
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
                    // TOGGLE CHI TIÊU / THU NHẬP
                    _buildTypeToggle(),

                    const SizedBox(height: 20),

                    // DANH MỤC
                    _buildLabel('Danh mục'),
                    const SizedBox(height: 8),
                    _buildCategorySelector(),

                    const SizedBox(height: 20),

                    // SỐ TIỀN
                    _buildLabel('Số tiền'),
                    const SizedBox(height: 8),
                    _buildAmountField(),

                    const SizedBox(height: 20),

                    // NGÀY GIAO DỊCH
                    _buildLabel('Ngày giao dịch'),
                    const SizedBox(height: 8),
                    _buildDateField(),

                    const SizedBox(height: 20),

                    // GHI CHÚ
                    _buildLabel('Ghi chú'),
                    const SizedBox(height: 8),
                    _buildNoteField(),
                  ],
                ),
              ),
            ),

            // NÚT LƯU
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final textAmount = amountController.text
                        .replaceAll('.', '')
                        .replaceAll(',', '')
                        .trim();
                    final amount = double.tryParse(textAmount);

                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng nhập số tiền hợp lệ'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final row = <String, dynamic>{
                      'type': isExpense ? 'Chi tiêu' : 'Thu nhập',
                      'category': category,
                      'amount': amount,
                      'date': formatDate(selectedDate),
                      'note': noteController.text.trim(),
                    };

                    if (widget.isEdit &&
                        widget.transaction != null &&
                        widget.transaction!['id'] != null) {
                      row['id'] = widget.transaction!['id'];
                      await DatabaseHelper.instance.updateTransaction(row);
                    } else {
                      await DatabaseHelper.instance.insertTransaction(row);
                    }

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            widget.isEdit
                                ? 'Đã cập nhật giao dịch'
                                : 'Đã lưu giao dịch',
                          ),
                        ),
                      );
                      Navigator.pop(context, true);
                    }
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
                    'Lưu',
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isExpense = true),
              child: Container(
                decoration: BoxDecoration(
                  color: isExpense ? const Color(0xFFEF4444) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Chi tiêu',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isExpense ? Colors.white : AppColors.darkText,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isExpense = false),
              child: Container(
                decoration: BoxDecoration(
                  color: !isExpense ? AppColors.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Thu nhập',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: !isExpense ? Colors.white : AppColors.darkText,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: categories.contains(category) ? category : categories.first,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.grayText),
          items: categories.map((cat) {
            return DropdownMenuItem<String>(
              value: cat,
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: CategoryHelper.getColor(cat).withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CategoryHelper.getIcon(cat),
                      size: 15,
                      color: CategoryHelper.getColor(cat),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    cat,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.darkText,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => category = val);
            }
          },
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return TextField(
      controller: amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        hintText: 'Nhập số tiền',
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        suffixText: 'đ',
        suffixStyle: const TextStyle(color: AppColors.grayText, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: selectDate,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                formatDate(selectedDate),
                style: const TextStyle(fontSize: 13, color: AppColors.darkText),
              ),
            ),
            const Icon(
              Icons.calendar_month_outlined,
              size: 20,
              color: AppColors.grayText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return TextField(
      controller: noteController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Nhập ghi chú (tùy chọn)',
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
      ),
    );
  }
}
