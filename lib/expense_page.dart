import 'package:flutter/material.dart';
import 'screens/transaction_form_screen.dart';

export 'screens/transaction_form_screen.dart';

class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TransactionFormScreen(isEdit: false);
  }
}

class EditTransactionScreen extends StatelessWidget {
  final Map<String, dynamic>? transaction;

  const EditTransactionScreen({super.key, this.transaction});

  @override
  Widget build(BuildContext context) {
    return TransactionFormScreen(isEdit: true, transaction: transaction);
  }
}
