import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:needs_app/config/app_config.dart';
import 'package:needs_app/config/colors.dart';
import 'package:needs_app/controllers/auth_controller.dart';
import 'package:needs_app/routes/app_routes.dart';

/// 启动页面 - 应用初始化加载页
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _initializeApp();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // 等待 1.5 秒后跳转
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        // 获取认证控制器
        final authController = Get.find<AuthController>();

        // 根据登录状态跳转到相应页面
        if (authController.isLoggedIn.value) {
          Get.offNamed(Routes.home);
        } else {
          Get.offNamed(Routes.login);
        }
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          '错误',
          '应用初始化失败: $e',
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: AppColors.error,
        );

        // 出错时跳转到登录页
        Get.offNamed(Routes.login);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Logo - 绿色圆角方形
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowColor,
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.agriculture,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 应用名称
                    Text(
                      AppConfig.appName,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 应用描述
                    Text(
                      '农产品供需撮合平台',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.white.withValues(alpha: 0.85),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
