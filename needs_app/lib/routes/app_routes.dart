import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:needs_app/screens/auth/login_screen.dart';
import 'package:needs_app/screens/auth/register_screen.dart';
import 'package:needs_app/screens/home/home_screen.dart';
import 'package:needs_app/screens/splash/splash_screen.dart';
import 'package:needs_app/screens/dispatch/ai_chat_screen.dart';
import 'package:needs_app/screens/order/order_list_screen.dart' as order_screen;

/// 路由名称常量
class Routes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String orderList = '/orders';
  static const String wallet = '/wallet';
  static const String profile = '/profile';
  static const String aiChat = '/ai-chat';
}

/// 路由配置类
class AppRoutes {
  /// 获取所有路由页面
  static final List<GetPage> pages = [
    // Splash 路由
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 500),
    ),

    // Home 路由
    GetPage(
      name: Routes.home,
      page: () => const HomeScreen(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Login 路由
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      // 登录页面防止返回
      preventDuplicates: true,
    ),

    // Register 路由
    GetPage(
      name: Routes.register,
      page: () => const RegisterScreen(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      preventDuplicates: true,
    ),

    // Order List 路由
    GetPage(
      name: Routes.orderList,
      page: () => const order_screen.OrderListScreen(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Wallet 路由
    GetPage(
      name: Routes.wallet,
      page: () => const WalletScreen(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Profile 路由
    GetPage(
      name: Routes.profile,
      page: () => const ProfileScreen(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // AI Chat 路由
    GetPage(
      name: Routes.aiChat,
      page: () {
        final orderId = Get.arguments as int?;
        return AiChatScreen(orderId: orderId);
      },
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}

/// Wallet Screen 占位符
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('钱包')),
      body: const Center(
        child: Text('Wallet Screen'),
      ),
    );
  }
}

/// Profile Screen 占位符
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人资料')),
      body: const Center(
        child: Text('Profile Screen'),
      ),
    );
  }
}
