import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:needs_app/controllers/auth_controller.dart';
import 'package:needs_app/screens/home/home_screen.dart';
import 'package:needs_app/screens/splash/splash_screen.dart';

/// 路由名称常量
class Routes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String orderList = '/orders';
  static const String wallet = '/wallet';
  static const String profile = '/profile';
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
      page: () => LoginScreen(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      // 登录页面防止返回
      preventDuplicates: true,
    ),

    // Register 路由
    GetPage(
      name: Routes.register,
      page: () => RegisterScreen(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      preventDuplicates: true,
    ),

    // Order List 路由
    GetPage(
      name: Routes.orderList,
      page: () => const OrderListScreen(),
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
  ];
}

/// Login Screen 占位符
class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: const Center(
        child: Text('Login Screen'),
      ),
    );
  }
}

/// Register Screen 占位符
class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: const Center(
        child: Text('Register Screen'),
      ),
    );
  }
}

/// Order List Screen 占位符
class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: const Center(
        child: Text('Order List Screen'),
      ),
    );
  }
}

/// Wallet Screen 占位符
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
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
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Text('Profile Screen'),
      ),
    );
  }
}
