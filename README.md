# Expenzia – Expense Management App

Expenzia is a Flutter-based expense management application designed to help users record expenses, organize transactions, and manage recurring or one-time credits in a simple interface.

## Features

- **Expense Management:** Add, edit, view, and delete expenses.
- **Category Tracking:** Organize expenses by category.
- **Transaction History:** View recorded expense transactions.
- **Credit Management:** Save and manage subscriptions, bills, and other credits.
- **Date Selection:** Select dates for expenses and credits.
- **Local Database:** Store data locally using SQLite.
- **Form Validation:** Validate required fields and amounts.
- **State Management:** Manage application state using Provider.

## Tech Stack

- **Framework:** Flutter
- **Language:** Dart
- **Architecture:** MVVM
- **State Management:** Provider
- **Database:** SQLite using `sqflite`
- **Date Formatting:** `intl`

## Project Structure

```text
lib/
├── database/
│   └── database_helper.dart
├── model/
│   └── expense_model.dart
├── view_model/
│   └── expense_viewmodel.dart
├── views/
│   ├── home_screen.dart
│   ├── add_edit_expense_screen.dart
│   ├── transaction_history_screen.dart
│   └── credit_screen.dart
└── main.dart
```

*The structure above represents the main files; adjust it to match the actual project.*

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- An Android emulator or physical device

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/Abhi-shek-26/expensia.git
   ```

2. Open the project directory:

   ```bash
   cd expensia
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Run the application:

   ```bash
   flutter run
   ```

## Database

Expenzia uses SQLite for local data storage. Expense and credit records are stored in local database tables, allowing data to remain available between application launches.

## Future Improvements

- Expense analytics and charts
- Monthly spending summaries
- Budget planning
- Data export and backup
- Dark mode support

## Author

**Abhishek P**

GitHub: [Abhi-shek-26](https://github.com/Abhi-shek-26)

## License

This project is intended for educational and portfolio purposes.
