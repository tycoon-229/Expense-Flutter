import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/category/presentation/pages/category_management_page.dart';
import '../../features/expense/domain/entities/expense.dart';
import '../../features/expense/presentation/pages/add_expense_page.dart';
import '../../features/expense/presentation/pages/expense_analytics_page.dart';
import '../../features/home/presentation/pages/main_navigation_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/recurring/presentation/pages/recurring_transactions_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../services/presentation/pages/notification_settings_page.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
    ),
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final location = state.matchedLocation;
      final isAuthRoute = location == '/login' || location == '/register';
      final isSplashRoute = location == '/splash';

      // Để SplashPage tự xử lý kiểm tra phiên lúc khởi động
      if (isSplashRoute) return null;

      if (session == null && !isAuthRoute) return '/login';
      if (session != null && isAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const MainNavigationPage(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const ExpenseAnalyticsPage(),
      ),
      GoRoute(
        path: '/add',
        builder: (context, state) => const AddExpensePage(),
      ),
      GoRoute(
        path: '/edit',
        builder: (context, state) {
          final expense = state.extra as Expense?;
          return AddExpensePage(expense: expense);
        },
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoryManagementPage(),
      ),
      GoRoute(
        path: '/recurring',
        builder: (context, state) => const RecurringTransactionsPage(),
      ),
      GoRoute(
        path: '/notification-settings',
        builder: (context, state) => const NotificationSettingsPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
}