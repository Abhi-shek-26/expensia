
import 'package:expensetracker/view/credit_screen.dart';
import 'package:expensetracker/view/transactionhistory_screen.dart';
import 'package:expensetracker/view_model/expense_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/expense_model.dart';
import 'addeditexpense_screen.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color teal = Color(0xFF2D817C);
  static const Color background = Color(0xFFF7F9F9);

  String formatAmount(double amount) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 2,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Expenzia',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Transaction history',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TransactionhistoryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history_rounded),
          ),IconButton(
            tooltip: ' Credits',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreditScreen(),
                ),
              );
            },
            icon: const Icon(Icons.credit_card),
          ),
          IconButton(
            onPressed: () {
              context.read<ExpenseViewmodel>().loadExpenses();
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Consumer<ExpenseViewmodel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.expenses.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: teal),
            );
          }

          if (viewModel.errorMessage != null &&
              viewModel.expenses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: viewModel.loadExpenses,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: teal,
            onRefresh: viewModel.loadExpenses,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Good day 👋',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manage your expenses',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222B2A),
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: teal,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: teal.withValues(alpha: 0.22),
                        blurRadius: 15,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Expenses',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatAmount(viewModel.totalExpenses),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 29,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          const Icon(
                            Icons.receipt_long_rounded,
                            color: Colors.white70,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${viewModel.expenses.length} transactions',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _SummaryCard(
                      title: 'Transactions',
                      value: '${viewModel.expenses.length}',
                      icon: Icons.receipt_long_rounded,
                      color: const Color(0xFF398C86),
                    ),
                    const SizedBox(width: 14),
                    _SummaryCard(
                      title: 'Average Expense',
                      value: viewModel.expenses.isEmpty
                          ? '₹ 0.00'
                          : formatAmount(
                        viewModel.totalExpenses /
                            viewModel.expenses.length,
                      ),
                      icon: Icons.analytics_outlined,
                      color: const Color(0xFF8871C8),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${viewModel.expenses.length} items',
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (viewModel.expenses.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 55,
                          color: teal,
                        ),
                        SizedBox(height: 14),
                        Text(
                          'No expenses yet',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Tap the + button to record your first expense.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...viewModel.expenses.take(5).map(
                        (expense) => _ExpenseTile(
                      expense: expense,
                      amount: formatAmount(expense.amount),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditExpenseScreen(
                              expense: expense,
                            ),
                          ),
                        );
                      },
                      onDelete: () => _confirmDelete(
                        context,
                        expense,
                      ),
                    ),
                  ),
                const SizedBox(height: 90),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: teal,
        foregroundColor: Colors.white,
        elevation: 5,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditExpenseScreen(),
            ),
          );
        },
        child: const Icon(Icons.add_rounded, size: 30),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context,
      ExpenseModel expense,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete expense?'),
        content: Text(
          'Are you sure you want to delete "${expense.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success = await context
        .read<ExpenseViewmodel>()
        .deleteExpense(expense.id!);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Expense deleted successfully'
              : 'Failed to delete expense',
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(minHeight: 120),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 13),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final ExpenseModel expense;
  final String amount;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ExpenseTile({
    required this.expense,
    required this.amount,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 7,
        ),
        onTap: onTap,
        leading: Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: const Color(0xFF2D817C).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            color: Color(0xFF2D817C),
          ),
        ),
        title: Text(
          expense.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            '${expense.category} • ${DateFormat('dd MMM yyyy').format(expense.date)}',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 11,
            ),
          ),
        ),
        trailing: SizedBox(
          width: 105,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  amount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF2D817C),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                iconSize: 20,
                onSelected: (value) {
                  if (value == 'edit') onTap();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
