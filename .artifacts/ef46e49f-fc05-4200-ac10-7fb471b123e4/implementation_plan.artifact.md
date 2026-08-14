# Simple Expense Management App Plan

Build a simple expense management app using Flutter, Dart, and Clean Architecture.

## User Review Required

> [!IMPORTANT]
> The app will use **Local SQLite (via Hive or Drift)** for simplicity by default, as requested. However, the architecture will be ready to switch to **Supabase** if needed.
> I will use `flutter_bloc` for state management and `get_it`/`injectable` for Dependency Injection.
> For UI/Animations, I'll use `animate_do` and custom animations.
> For Charts, I'll use `fl_chart`.

## Proposed Changes

### Project Setup
- Update `pubspec.yaml` with:
    - `flutter_bloc`, `bloc`
    - `get_it`, `injectable`
    - `hive`, `hive_flutter`
    - `freezed_annotation`, `json_annotation`
    - `go_router`
    - `fl_chart`
    - `intl` (for date/currency formatting)
    - Dev dependencies: `build_runner`, `injectable_generator`, `freezed`, `hive_generator`, `json_serializable`

### Clean Architecture Layers

#### Core
- DI configuration (`injection.dart`)
- Error handling (`failure.dart`)
- UseCase base class

#### Features: Expense
- **Domain Layer**:
    - `Expense` entity
    - `ExpenseRepository` interface
    - UseCases: `GetExpenses`, `AddExpense`, `UpdateExpense`, `DeleteExpense`
- **Data Layer**:
    - `ExpenseModel` (Hive compatible)
    - `ExpenseLocalDataSource` (Hive implementation)
    - `ExpenseRepositoryImpl`
- **Presentation Layer**:
    - `ExpenseBloc` (using `flutter_bloc`)
    - `ExpenseListScreen`
    - `AddExpenseScreen`
    - Widgets: `ExpenseSummaryChart`, `ExpenseItem`

### UI & Animation
- Material 3 Design
- Smooth transitions using `PageTransitions` in `go_router`
- Entrance animations for list items

## Verification Plan

### Automated Tests
- Unit tests for UseCases and Bloc
- Widget tests for the list screen

### Manual Verification
- Run the app on an emulator/device
- Perform CRUD operations
- Verify chart updates
- Check UI responsiveness and animations
