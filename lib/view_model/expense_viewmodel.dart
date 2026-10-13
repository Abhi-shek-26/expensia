import 'package:flutter/cupertino.dart';

import '../database/database_helper.dart';
import '../model/expense_model.dart';

class ExpenseViewmodel extends ChangeNotifier{
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  List<ExpenseModel> _expenses = [];
  double _totalExpenses = 0.0;
  bool _isLoading = false;
  String? _errorMessage;

  List<ExpenseModel>get expenses => List.unmodifiable(_expenses);
  double get totalExpenses => _totalExpenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadExpenses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try{
      _expenses = await _databaseHelper.getExpenses();
      _totalExpenses = await _databaseHelper.getTotalExpenses();
    }catch (e){
      _errorMessage = 'Unable to load expenses';
    }finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool>addExpence(ExpenseModel expense)async{
    try{
      await _databaseHelper.insertExpense(expense);
      await loadExpenses();
      return true;
    }catch (e){
      _errorMessage = 'Unable to add expense';
      notifyListeners();
      return false;
    }
  }


  Future<bool>updateExpense(ExpenseModel expense)async{
    try{
      await _databaseHelper.updateExpense(expense);
      await loadExpenses();
      return true;
    }catch (e){
      _errorMessage = "Unable to update";
      notifyListeners();
      return false;
    }
  }

  Future<bool>deleteExpense(int id )async{
    try{
      await _databaseHelper.deleteExpense(id);
      await loadExpenses();
      return true;
    }catch (e){
      _errorMessage = "unable to delete";
      notifyListeners();
      return false;
    }
  }

}