import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/di/injection.dart';
import 'core/navigation/app_router.dart';
import 'core/config/supabase_config.dart';

import 'core/services/daily_reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Điền URL và Anon Key từ project Supabase của bạn
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
  );

  configureDependencies();

  // Khởi tạo dịch vụ nhắc nhở hàng ngày
  await DailyReminderService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Quản lý chi tiêu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
    );
  }
}