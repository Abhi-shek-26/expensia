
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/expense_model.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final databasePath = join(
      await getDatabasesPath(),
      'expenzia.db',
    );

    _database = await openDatabase(
      databasePath,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL CHECK(amount > 0),
            category TEXT NOT NULL,
            date TEXT NOT NULL,
            description TEXT NOT NULL DEFAULT ''
          )
        ''');

        await db.execute('''
          CREATE TABLE credits (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            creditType TEXT NOT NULL,
            name TEXT NOT NULL,
            date TEXT NOT NULL,
            planType TEXT NOT NULL,
            amount REAL NOT NULL CHECK(amount > 0)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE credits (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              creditType TEXT NOT NULL,
              name TEXT NOT NULL,
              date TEXT NOT NULL,
              planType TEXT NOT NULL,
              amount REAL NOT NULL CHECK(amount > 0)
            )
          ''');
        }
      },
    );

    return _database!;
  }

  Future<List<ExpenseModel>> getExpenses() async {
    final db = await database;

    final result = await db.query(
      'expenses',
      orderBy: 'date DESC, id DESC',
    );

    return result.map(ExpenseModel.fromMap).toList();
  }

  Future<int> insertExpense(ExpenseModel expense) async {
    final db = await database;

    return db.insert(
      'expenses',
      expense.toMap()..remove('id'),
    );
  }

  Future<int> updateExpense(ExpenseModel expense) async {
    if (expense.id == null) {
      throw ArgumentError('Expense ID is required for updating.');
    }

    final db = await database;

    return db.update(
      'expenses',
      expense.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;

    return db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalExpenses() async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT SUM(amount) AS total FROM expenses',
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> insertCredit(Map<String, dynamic> credit) async {
    final db = await database;
    final data = Map<String, dynamic>.from(credit)..remove('id');

    return db.insert('credits', data);
  }

  Future<List<Map<String, dynamic>>> getCredits() async {
    final db = await database;

    return db.query(
      'credits',
      orderBy: 'date DESC, id DESC',
    );
  }

  Future<int> updateCredit(Map<String, dynamic> credit) async {
    final id = credit['id'];

    if (id == null) {
      throw ArgumentError('Credit ID is required for updating.');
    }

    final data = Map<String, dynamic>.from(credit)..remove('id');
    final db = await database;

    return db.update(
      'credits',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCredit(int id) async {
    final db = await database;

    return db.delete(
      'credits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalCredits() async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT SUM(amount) AS total FROM credits',
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
