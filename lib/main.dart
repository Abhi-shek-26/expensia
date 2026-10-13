
import 'package:expensetracker/view/home_screen.dart';
import 'package:expensetracker/view_model/expense_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



void main() {
  runApp(const ExpenziaApp());
}

class ExpenziaApp extends StatelessWidget {
  const ExpenziaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpenseViewmodel()..loadExpenses(),
      child: MaterialApp(
        title: 'Expenzia',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF7F9F9),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2D817C),
            primary: const Color(0xFF2D817C),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2D817C),
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
