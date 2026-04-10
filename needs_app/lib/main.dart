import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:needs_app/config/app_config.dart';
import 'package:needs_app/config/colors.dart';
import 'package:needs_app/controllers/auth_controller.dart';
import 'package:needs_app/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');

  // 初始化 AuthController
  Get.put<AuthController>(AuthController());

  runApp(const NeedsApp());
}

class NeedsApp extends StatelessWidget {
  const NeedsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConfig.appName,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        primarySwatch: Colors.green,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        primaryColor: AppColors.primary,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
      ),
      themeMode: ThemeMode.system,
      initialRoute: Routes.splash,
      getPages: AppRoutes.pages,
      debugShowCheckedModeBanner: AppConfig.isDevelopment,
    );
  }
}
