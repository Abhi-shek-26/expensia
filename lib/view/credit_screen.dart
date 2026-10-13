
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';

class CreditScreen extends StatefulWidget {
  const CreditScreen({super.key});

  @override
  State<CreditScreen> createState() => _CreditScreenState();
}

class _CreditScreenState extends State<CreditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  String _creditType = 'Subscriptions';
  String _planType = 'Monthly';
  DateTime _selectedDate = DateTime.now();

  List<Map<String, dynamic>> _savedCredits = [];

  bool _isLoading = true;
  bool _isSaving = false;

  final Color primaryColor = const Color(0xFF2D817C);

  @override
  void initState() {
    super.initState();
    _loadCredits();
  }

  Future<void> _loadCredits() async {
    try {
      final credits = await DatabaseHelper.instance.getCredits();

      if (!mounted) return;

      setState(() {
        _savedCredits = credits;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load saved credits'),
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveCredit() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || !amount.isFinite || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid amount'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await DatabaseHelper.instance.insertCredit({
        'creditType': _creditType,
        'name': _nameController.text.trim(),
        'date': _selectedDate.toIso8601String(),
        'planType': _planType,
        'amount': amount,
      });

      if (!mounted) return;

      _nameController.clear();
      _amountController.clear();

      setState(() {
        _selectedDate = DateTime.now();
        _creditType = 'Subscriptions';
        _planType = 'Monthly';
      });

      await _loadCredits();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credit saved successfully'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save credit'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteCredit(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Credit'),
          content: const Text(
            'Are you sure you want to delete this credit?',
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
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await DatabaseHelper.instance.deleteCredit(id);
      await _loadCredits();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credit deleted successfully'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete credit'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Credit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('CREDIT TYPE'),
                  DropdownButtonFormField<String>(
                    value: _creditType,
                    decoration: _decoration(),
                    items: const [
                      DropdownMenuItem(
                        value: 'Subscriptions',
                        child: Text('Subscriptions'),
                      ),
                      DropdownMenuItem(
                        value: 'Bills',
                        child: Text('Bills'),
                      ),
                      DropdownMenuItem(
                        value: 'Other',
                        child: Text('Other'),
                      ),
                    ],
                    onChanged: _isSaving
                        ? null
                        : (value) {
                      if (value != null) {
                        setState(() => _creditType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _fieldLabel('TO'),
                  TextFormField(
                    controller: _nameController,
                    enabled: !_isSaving,
                    decoration: _decoration(
                      hint: 'Enter name',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _fieldLabel('DATE'),
                  InkWell(
                    onTap: _isSaving ? null : _pickDate,
                    child: InputDecorator(
                      decoration: _decoration(
                        suffixIcon: const Icon(
                          Icons.calendar_month_outlined,
                          size: 20,
                        ),
                      ),
                      child: Text(
                        DateFormat('EEE, dd MMM yyyy')
                            .format(_selectedDate),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _fieldLabel('PLAN TYPE'),
                  DropdownButtonFormField<String>(
                    value: _planType,
                    decoration: _decoration(),
                    items: const [
                      DropdownMenuItem(
                        value: 'Monthly',
                        child: Text('Monthly'),
                      ),
                      DropdownMenuItem(
                        value: 'One-Time',
                        child: Text('One-Time'),
                      ),
                    ],
                    onChanged: _isSaving
                        ? null
                        : (value) {
                      if (value != null) {
                        setState(() => _planType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _fieldLabel('AMOUNT'),
                  TextFormField(
                    controller: _amountController,
                    enabled: !_isSaving,
                    keyboardType:
                    const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: _decoration(
                      hint: 'Enter amount',
                    ),
                    validator: (value) {
                      final amount = double.tryParse(
                        value?.trim() ?? '',
                      );

                      if (amount == null ||
                          !amount.isFinite ||
                          amount <= 0) {
                        return 'Enter a valid amount';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveCredit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                        primaryColor.withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Save',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Your Saved Lists',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_savedCredits.isEmpty)
              const Padding(
                padding: EdgeInsets.only(
                  top: 12,
                  bottom: 20,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'No saved credits yet',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              ..._savedCredits.map((credit) {
                final id = credit['id'] as int;
                final date = DateTime.parse(
                  credit['date'] as String,
                );
                final plan = credit['planType'] as String;
                final amount = (credit['amount'] as num).toDouble();
                final name = credit['name'] as String;
                final creditType = credit['creditType'] as String;

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFECECEC),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$creditType • Due '
                                  '${DateFormat('dd/MM/yy').format(date)}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            plan,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            NumberFormat.currency(
                              locale: 'en_IN',
                              symbol: '₹ ',
                              decimalDigits: 2,
                            ).format(amount),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        tooltip: 'Delete credit',
                        onPressed: () => _deleteCredit(id),
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 19,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  InputDecoration _decoration({
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFFE1E1E1),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFFE1E1E1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor),
      ),
    );
  }
}
