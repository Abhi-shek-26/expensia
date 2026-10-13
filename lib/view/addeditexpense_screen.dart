
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/expense_model.dart';
import '../view_model/expense_viewmodel.dart';



class AddEditExpenseScreen extends StatefulWidget {
  final ExpenseModel? expense;

  const AddEditExpenseScreen({
    super.key,
    this.expense,
  });

  @override
  State<AddEditExpenseScreen> createState() =>
      _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState
    extends State<AddEditExpenseScreen> {
  static const Color teal = Color(0xFF2D817C);

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _categories = [
    'Food',
    'Travel',
    'Shopping',
    'Bills',
    'Health',
    'Education',
    'Entertainment',
    'Other',
  ];

  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();

    final expense = widget.expense;

    if (expense != null) {
      _titleController.text = expense.title;
      _amountController.text = expense.amount.toString();
      _descriptionController.text = expense.description;
      _selectedCategory = expense.category;
      _selectedDate = expense.date;

      if (!_categories.contains(expense.category)) {
        _categories.add(expense.category);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: teal,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _selectedDate = selected);
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final expense = ExpenseModel(
      id: widget.expense?.id,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      category: _selectedCategory!,
      date: _selectedDate,
      description: _descriptionController.text.trim(),
    );

    final viewModel = context.read<ExpenseViewmodel>();

    final success = _isEditing
        ? await viewModel.updateExpense(expense)
        : await viewModel.addExpence(expense);

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Expense updated successfully'
                : 'Expense added successfully',
          ),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.errorMessage ?? 'Something went wrong',
          ),
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFE5E9E9)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFE5E9E9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: teal, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Transaction' : 'Transaction',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 19),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.035),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: 'Expense',
                      decoration: _inputDecoration('Transaction Type'),
                      items: const [
                        DropdownMenuItem(
                          value: 'Expense',
                          child: Text('Expense'),
                        ),
                      ],
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _titleController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _inputDecoration('Expense Title'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an expense title';
                        }
                        if (value.trim().length > 100) {
                          return 'Title cannot exceed 100 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _inputDecoration('Amount (₹)').copyWith(
                        prefixText: '₹ ',
                      ),
                      validator: (value) {
                        final amount = double.tryParse(
                          value?.trim() ?? '',
                        );

                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an amount';
                        }

                        if (amount == null ||
                            !amount.isFinite ||
                            amount <= 0) {
                          return 'Enter a valid positive amount';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: _inputDecoration('Category'),
                      hint: const Text('Select category'),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Date',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(13),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFE5E9E9),
                          ),
                          borderRadius: BorderRadius.circular(13),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                DateFormat(
                                  'EEE, dd MMM yyyy',
                                ).format(_selectedDate),
                              ),
                            ),
                            const Icon(
                              Icons.calendar_month_rounded,
                              color: teal,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      maxLength: 300,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _inputDecoration(
                        'Description (Optional)',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: teal,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: teal.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    _isEditing ? 'Update Expense' : 'Save',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
