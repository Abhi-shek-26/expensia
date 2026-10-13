import 'package:expensetracker/model/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../view_model/expense_viewmodel.dart';
import 'addeditexpense_screen.dart';

class TransactionhistoryScreen extends StatefulWidget {
  const TransactionhistoryScreen({super.key});

  @override
  State<TransactionhistoryScreen> createState() => _TransactionhistoryScreenState();
}

class _TransactionhistoryScreenState extends State<TransactionhistoryScreen> {
  static const Color teal = Color(0xff2d817c);

  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Food',
    'Travel',
    'Shopping',
    'Bills',
    'Health',
    'Education',
    'Entertainment',
    'Other',
  ];

  String _formatAmount(double amount){
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 2,
    ).format(amount);
  }

  List<ExpenseModel> _filterExpenses(List<ExpenseModel> expenses) {
    return expenses.where((expense) {
      final matchesCategory = _selectedCategory == 'All' ||
          expense.category == _selectedCategory;

      final query = _searchQuery.toLowerCase();

      final matchesSearch = expense.title.toLowerCase().contains(query) ||
          expense.category.toLowerCase().contains(query) ||
          expense.description.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteExpense(
      BuildContext context,
      ExpenseModel expense,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete expense?'),
        content: Text('Delete "${expense.title}" permanently?'),
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
          success ? 'Expense deleted' : 'Unable to delete expense',
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffff7f9f9),
      appBar: AppBar(
        title: const  Text("Transaction History",style:TextStyle(
          fontWeight: FontWeight.w600
        ),
        ),
      ),
      body: Consumer<ExpenseViewmodel>(
          builder: (context,viewmodel,child){
            final expenses = _filterExpenses(viewmodel.expenses);
            return Column(
              children: [
                Padding(padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => _searchQuery = value.trim());
                  },
                  decoration: InputDecoration(
                    hintText: 'Search expenses...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: teal,
                    ),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                ),
                SizedBox(height: 45,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final selected = category == _selectedCategory;

                    return ChoiceChip(
                      label: Text(category),
                      selected: selected,
                      selectedColor: teal,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      onSelected: (_) {
                        setState(() => _selectedCategory = category);
                      },
                    );
                  },
                ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: viewmodel.isLoading && viewmodel.expenses.isEmpty
                      ? const Center(
                    child: CircularProgressIndicator(color: teal),
                  )
                      : expenses.isEmpty
                      ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.receipt_long_outlined,
                            size: 60,
                            color: teal,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            viewmodel.expenses.isEmpty
                                ? 'No expenses available'
                                : 'No matching expenses',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Try changing your search or category.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      4,
                      16,
                      20,
                    ),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding:
                          const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddEditExpenseScreen(
                                      expense: expense,
                                    ),
                              ),
                            );
                          },
                          leading: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: teal.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.receipt_long_rounded,
                              color: teal,
                            ),
                          ),
                          title: Text(
                            expense.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              '${expense.category} • ${DateFormat('dd MMM yyyy').format(expense.date)}',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          trailing: SizedBox(
                            width: 115,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Text(
                                    _formatAmount(expense.amount),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: teal,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  padding: EdgeInsets.zero,
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              AddEditExpenseScreen(
                                                expense: expense,
                                              ),
                                        ),
                                      );
                                    } else if (value == 'delete') {
                                      _deleteExpense(
                                        context,
                                        expense,
                                      );
                                    }
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
                    },
                  ),
                ),
              ],
            );
          },
      ),
    );
  }
}
